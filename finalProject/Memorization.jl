using Knet
module Memorization
using Main, Knet, ArgParse
using Knet: copysync!
include("Data.jl")
@useifgpu CUDArt
@useifgpu CUSPARSE

function main(args=ARGS)
    info("Learning to copy sequences to test the S2S model.")
    s = ArgParseSettings()
    @add_arg_table s begin
        ("datafiles"; nargs='+'; required=true; help="First file used for training")
        ("--dictfile"; help="Dictionary file, first datafile used if not specified")
        ("--epochs"; arg_type=Int; default=1)
        ("--hidden"; arg_type=Int; default=100)
        ("--batchsize"; arg_type=Int; default=128)
        ("--lossreport"; arg_type=Int; default=0)
        ("--gclip"; arg_type=Float64; default=10.0)
        ("--lr"; arg_type=Float64; default=2.0)
        ("--fbias"; arg_type=Float64; default=0.0)
        ("--ftype"; default="Float32")
        ("--winit"; default="Gaussian(0,0.01)")
        ("--dense"; action=:store_true)
        ("--fast"; help="skip norm and loss calculations."; action=:store_true)
        ("--gcheck"; arg_type=Int; default=0)
        ("--seed"; arg_type=Int; default=42)
        ("--nosharing"; action = :store_true)
    end
    isa(args, AbstractString) && (args=split(args))
    opts = parse_args(args, s)
    println(opts)
    for (k,v) in opts; @eval ($(symbol(k))=$v); end
    seed > 0 && setseed(seed)

    dict = (dictfile == nothing ? datafiles[1] : dictfile)
    readData("Input.txt", "Output.txt", "SourceDict", SourceDict)
    global model = compile(:rnn_model; fbias=fbias, out=hidden, numbers=length(indict))
    setp(model; lr=lr)

    #
    # if nosharing
    #     set!(model, :forwoverwrite, false)
    #     set!(model, :backoverwrite, false)
    # end

    perp = zeros(1)
    (maxnorm,losscnt) = fast ? (nothing,nothing) : (zeros(2),zeros(2))
    t0 = time_ns()

    for epoch=1:epochs
      fast || (fill!(maxnorm,0); fill!(losscnt,0))
      train(model, softloss; gclip=gclip, maxnorm=maxnorm, losscnt=losscnt, lossreport=lossreport)
      fast || (perp[1] = exp(losscnt[1]/losscnt[2]))
      myprint(epoch, (time_ns()-t0)/1e9, perp..., (fast ? [] : maxnorm)...)
      gcheck > 0 && gradcheck(model,
                            f->(train(f,softloss;losscnt=fill!(losscnt,0),gcheck=true);losscnt[1]),
                            f->(test(f,softloss;losscnt=fill!(losscnt,0),gcheck=true);losscnt[1]);
                            gcheck=gcheck)
    end
    return (fast ? (perp...) :  (perp..., maxnorm...))
end



@knet function rnn_model(character; fbias=0, numbers=47, nlayer=2, o...)
    if !decoding
        h = lstm2(character; nlayer=nlayer,o...)
    else
        h = lstm2(character; nlayer=nlayer,o...)
    end

    if decoding
        target = wdot(h; out=numbers)
        return soft(target)
    end
end

@knet function lstm2(x; nlayer=0, embedding=0, hidden=0, o...)
    a = wdot(x; out=hidden)
    c = repeat(a; frepeat=:firstLayer, nrepeat=nlayer, o...)
    return c
end

@knet function firstLayer(x; fbias= 0.08, o...)
    input  = wbf3(x,h,cell; o..., f=:sigm, binit=Uniform(-fbias,fbias))
    forget = wbf3(x,h,cell; o..., f=:sigm, binit=Uniform(-fbias,fbias))
    newmem = wbf2(x,h; o..., f=:tanh, binit=Uniform(-fbias,fbias))
    cell = input .* newmem + cell .* forget
    h  = tanh(cell) .* output
    return h
end

@knet function wbf3(x1, x2, x3; f=:sigm, o...)
    y1 = wdot(x1; o...)
    y2 = wdot(x2; o...)
    y3 = wdot(x3, o...)
    x3 = add(y2,y1)
    x4 = add(x3,y3)
    y4 = bias(x4; o...)
    return f(y4; o...)
end

function train(m, loss; o...)
    s2s_loop(m, loss; trn=true, ystack=Any[], o...)
end

function test(m, loss; losscnt=zeros(2), o...)
    s2s_loop(m, loss; losscnt=losscnt, o...)
    losscnt[1]/losscnt[2]
end

# Persistent storage for ygold and mask
s2s_ygold = nothing
s2s_mask = nothing
@gpu copytogpu(y,x::Array)=CudaArray(x)
@gpu copytogpu(y,x::SparseMatrixCSC)=CudaSparseMatrixCSC(x)
@gpu copytogpu{T}(y::CudaArray{T},x::Array{T})=(size(x)==size(y) ? copysync!(y,x) : copytogpu(nothing,x))
@gpu copytogpu{T}(y::CudaSparseMatrixCSC{T},x::SparseMatrixCSC{T})=(size(x)==size(y) ? copysync!(y,x) : copytogpu(nothing,x))


function s2s_loop(m, loss; gcheck=false, o...)
    global s2s_ygold, s2s_mask
    s2s_lossreport()
    decoding = false
    reset!(m)
    for batchNo = 1:length(x)
      for j=1:size(x[batchNo],2)

        x = dataX[batchNo][:,:,j]
        ygold = dataY[batchNo][:,:,j]
        mask = nothing

        nwords = (mask == nothing ? size(x,2) : sum(mask))
        # x,ygold,mask are cpu arrays; x gets copied to gpu by forw; we should do the other two here
        if ygold != nothing && gpu()
            ygold = s2s_ygold = copytogpu(s2s_ygold,ygold)
            mask != nothing && (mask = s2s_mask  = copytogpu(s2s_mask,mask)) # mask not used when ygold=nothing
        end
        if decoding && ygold ==  # the next sentence started
            gcheck && break
            s2s_eos(m, loss; gcheck=gcheck, o...)
            reset!(m)
            decoding = false
        end
        if !decoding && ygold != nothing # source ended, target sequence started
            # s2s_copyforw!(m)
            decoding = true
        end
        if decoding && ygold != nothing # keep decoding target
            s2s_decode(m, x, ygold, mask, nwords, loss; o...)
        end
        if !decoding && ygold == nothing # keep encoding source
            s2s_encode(m, x; o...)
        end
      end
    end
    s2s_eos(m, loss; gcheck=gcheck, o...)
end

function s2s_encode(m, x; trn=false, o...)
    # forw(m.encoder, x; trn=trn, seq=true, o...)
    (trn?sforw:forw)(m, x; decoding=false)
end

function s2s_decode(m, x, ygold, mask, nwords, loss; trn=false, ystack=nothing, losscnt=nothing, o...)
    # ypred = forw(m.decoder, x; trn=trn, seq=true, o...)
    ypred = (trn?sforw:forw)(m, x; decoding=true)
    ystack != nothing  && push!(ystack, (copy(ygold),copy(mask))) # TODO: get rid of alloc
    losscnt != nothing && s2s_loss(m, ypred, ygold, mask, nwords, loss; losscnt=losscnt, o...)
end

function s2s_loss(m, ypred, ygold, mask, nwords, loss; losscnt=nothing, lossreport=0, o...)
    (yrows, ycols) = size2(ygold)  # TODO: loss should handle mask, currently only softloss does.
    losscnt[1] += loss(ypred,ygold;mask=mask) # loss divides total loss by minibatch size ycols.  at the end the total loss will be equal to
    losscnt[2] += nwords/ycols                # losscnt[1]*ycols.  losscnt[1]/losscnt[2] will equal totalloss/totalwords.
    # we could scale losscnt with ycols so losscnt[1] is total loss and losscnt[2] is total words, but I think that breaks gradcheck since the scaled versions are what gets used for parameter updates in order to prevent batch size from effecting step size.
    lossreport > 0 && s2s_lossreport(losscnt,ycols,lossreport)
end

function s2s_eos(m, loss; trn=false, gcheck=false, ystack=nothing, maxnorm=nothing, gclip=0, o...)
    if trn
        s2s_bptt(m, ystack, loss; o...)
        g = (gclip > 0 || maxnorm!=nothing ? gnorm(m) : 0)
        if !gcheck
            gscale=(g > gclip > 0 ? gclip/g : 1)
            update!(m; gscale=gscale, o...)
        end
    end
    if maxnorm != nothing
        w=wnorm(m)
        w > maxnorm[1] && (maxnorm[1]=w)
        g > maxnorm[2] && (maxnorm[2]=g)
    end
end

function s2s_bptt(m, ystack, loss; o...)
    while !isempty(ystack)
        (ygold,mask) = pop!(ystack)
        # back(m.decoder, ygold, loss; seq=true, mask=mask, o...)
        sback(m, ygold, loss; mask=mask, o...) # back passes mask on to loss
    end
    # @assert m.decoder.sp == 0
    # s2s_copyback!(m)
    # while m.encoder.sp > 0
    while m.sp > 0
        # back(m.encoder; seq=true, o...)
        sback(m)                # TODO: what about mask here?
        # error(:ok)
    end
end

s2s_time0 = s2s_time1 = s2s_inst = 0

function s2s_lossreport()
    global s2s_time0, s2s_time1, s2s_inst
    s2s_inst = 0
    s2s_time0 = s2s_time1 = time_ns()
    # println("time inst speed perp")
end

s2s_print(a...)=(for x in a; @printf("%.2f ",x); end; println(); flush(STDOUT))

function s2s_lossreport(losscnt,batchsize,lossreport)
    global s2s_time0, s2s_time1, s2s_inst
    s2s_time0 == 0 && s2s_lossreport()
    losscnt == nothing && return
    losscnt[2]*batchsize < lossreport && return
    curr_time = time_ns()
    batch_time = Int(curr_time - s2s_time1)/10^9
    total_time = Int(curr_time - s2s_time0)/10^9
    s2s_time1 = curr_time
    batch_inst = losscnt[2]*batchsize
    batch_loss = losscnt[1]*batchsize
    s2s_inst += batch_inst
    s2s_print(total_time, s2s_inst, batch_inst/batch_time, exp(batch_loss/batch_inst))
    losscnt[1] = losscnt[2] = 0
end


!isinteractive() && !isdefined(Core.Main, :load_only) && main(ARGS)

end # module

### DEAD CODE

    # info("Warm-up epoch")
    # f=datafiles[1]; mini = S2SData(f, f; batch=batchsize, ftype=eval(parse(ftype)), dense=dense, dict1=dict[1], dict2=dict[2], stop=3200)
    # @date train(model, mini, softloss; gcheck=gcheck, gclip=gclip, getnorm=getnorm, getloss=getloss) # pretrain to compile for timing
    # info("Starting profile")