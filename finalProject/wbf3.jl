@knet function wbf3(x1, x2, x3; f=:sigm, o...)
    y1 = wdot(x1; o...)
    y2 = wdot(x2; o...)
    y3 = wdot(x3, o...)
    x3 = add(y2,y1)
    x4 = add(x3,y3)
    y4 = bias(x4; o...)
    return f(y4; o...)
end

@knet function rnn_model(character; fbias=0, numbers=11, nlayer=2, o...)
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
