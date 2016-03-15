###  Username: eakyurek

isdefined(:MNIST) || include(Pkg.dir("Knet/examples/mnist.jl"))
using Knet

@knet function mnist_softmax(x)
    y1 = wbf(x; out=30, f=:relu)
    return wbf(y1; f=:soft, out=10)
end


function train(f, data, loss)
    for (x,y) in data
        forw(f, x)
        back(f, y, loss)
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
    for i=1:batchsize:ccount(x)
        j=min(i+batchsize-1,ccount(x))
        push!(data, (cget(x,i:j), cget(y,i:j)))
    end
    return data
end

function accuracy(ygold, ypred)
	correct = 0.0
	for i=1:size(ygold, 2)
		correct += indmax(ygold[:,i]) == indmax(ypred[:, i]) ? 1.0 : 0.0
	end
	return correct / size(ygold, 2)
end


function main()
	nepochs = 100
	batchsize = 100
  dtrn = minibatch(MNIST.xtrn,MNIST.ytrn,batchsize)
	dtst = minibatch(MNIST.xtst,MNIST.ytst,batchsize)
  global softlosstrn = zeros(nepochs)
	global zeroerrortrn = zeros(nepochs)
	global softlosstst = zeros(nepochs)
	global zeroerrortst = zeros(nepochs)
  model = compile(:mnist_softmax)
  setp(model; lr=0.15)

	for epoch=1:nepochs
			softlosstrn[epoch] = test(model,dtrn,softloss)
			zeroerrortrn[epoch] = test(model,dtrn,zeroone)
			softlosstst[epoch] = test(model,dtst,softloss)
			zeroerrortst[epoch] = test(model,dtst,zeroone)
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
	end

end

main()
