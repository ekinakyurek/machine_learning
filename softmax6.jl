# Handwritten digit recognition problem from http://yann.lecun.com/exdb/mnist.
# 4-D convolution test

isdefined(:MNIST) || include(Pkg.dir("Knet/examples/mnist.jl"))

using Knet,CUDArt
module MNIST4D
using Main, Knet, ArgParse



@knet function mnist_softmax(x0)
      x1 = cbfp(x0; out=16, f=:relu, cwindow=5, pwindow=2)
      x2 = cbfp(x1; out=14, f=:tanh, cwindow=5, pwindow=2)
      x3 = wbf(x2; out=13, f=:tanh)
      return wbf(x3; out=10, f=:soft)
end

function main(args=ARGS)
    batchsize = 100
    nepochs = 400
    global dtrn = minibatch(MNIST.xtrn, MNIST.ytrn, batchsize)
    global dtst = minibatch(MNIST.xtst, MNIST.ytst, batchsize)

    global model = compile(:mnist_softmax)
    setp(model; lr=0.22)

    for epoch=1:nepochs
        if epoch == 200
               setp(model;lr=0.20)
        end
	      if epoch == 250
               setp(model;lr=0.19)
        end
	      if epoch == 300
               setp(model;lr=0.18)
        end
	      if epoch == 350
               setp(model;lr=0.17)
        end


	      train(model, dtrn, softloss)
        @printf("%d\t%g\t%g\t%g\t%g\n",
                epoch,
                test(model, dtrn, softloss),
                test(model, dtst, softloss),
                test(model, dtrn, zeroone),
                test(model, dtst, zeroone)
                #accuracy(MNIST.ytrn,forw(model,MNIST.xtrn)),
                #accuracy(MNIST.ytst,forw(model,MNIST.xtst))
                )
        if test(model, dtrn, zeroone)==0.0
              break
         end
    end
end


function train(f, data, loss; losscnt=nothing, maxnorm=nothing)
    for (x,ygold) in data
        ypred = forw(f, x)
        back(f, ygold, loss)
        update!(f)
    end
end

function test(f, data, loss)
    sumloss = numloss = 0
    for (x,ygold) in data
        ypred = forw(f, x)
        sumloss += loss(ypred, ygold)
        numloss += 1
    end
    sumloss / numloss
end

function minibatch(x, y, batchsize)
    data = Any[]
    for i=1:batchsize:ccount(x)-batchsize+1
        j=i+batchsize-1
        push!(data, (cget(x,i:j), cget(y,i:j)))
    end
    return data
end

function getgrad(f, data, loss)
    (x,ygold) = first(data)
    ypred = forw(f, x)
    back(f, ygold, loss)
    loss(ypred, ygold)
end

function getloss(f, data, loss)
    (x,ygold) = first(data)
    ypred = forw(f, x)
    loss(ypred, ygold)
end

main()

end # module
