###
###  In this assignment, you will implement a softmax classifier in Julia.
###  You are not allowed to use Knet.
###  You should complete functions using Julia functions.
###
###  Please, refer http://ai.ku.edu.tr/knet/dev/softmax.html for softmax
###
###  Additional references:
###  http://ufldl.stanford.edu/tutorial/supervised/SoftmaxRegression/
###  http://ufldl.stanford.edu/tutorial/supervised/DebuggingGradientChecking/

###  DO NOT USE Knet!
###  DO NOT USE Knet!
###  DO NOT USE Knet!

###  Username: eakyurek

include(Pkg.dir("Knet/examples/mnist.jl"))

function main()
	#============================
	MNIST.xtrn, MNIST.ytrn
	MNIST.xtst, MNIST.ytst
	============================#

	# Size of input vector (MNIST images are 28x28)
	ninputs = 28 * 28

	# Number of classes (MNIST images fall into 10 classes)
	noutputs = 10

	## STEP 1: Load data
	#
	#  In this section, we load the input and output data,
	#  prepare data to feed into softmax model.
	#  For softmax regression on MNIST pixels,
	#  the input data is the images, and
	#  the output data is the labels.
	#  Size of xtrn: (28,28,1,60000)
	#  You should flatten image matrices
	#  Size of xtrn must be: (784, 60000)
	#  Size of xtst must be: (784, 10000)

	ytrn = MNIST.ytrn
	ytst = MNIST.ytst

	#  start of step1

	#YOUR CODE HERE
	xtrn = zeros(ninputs,size(MNIST.xtrn,4))
	xtst = zeros(ninputs,size(MNIST.xtst,4))

	for i = 1 : size(xtrn,2)
		xtrn[:,i] = reshape(MNIST.xtrn[:,:,1,i],784,1)
	end

	for j = 1 : size(xtst,2)
		xtst[:,j] = reshape(MNIST.xtst[:,:,1,j],784,1)
	end

	#  end of step1


	## STEP 2: Initialize parameters
	#  Complete init_params function
	#  It takes number of inputs and number of outputs(number of classes)
	#  It returns W matrix which is randomly generated from a Gaussian distribution with mean=0, std=0.001
	#  and bias vector which is zeros vector
	#  Size of W must be (noutputs x ninputs)
	#  Size of b must be (noutputs x 1)

	W, b = init_params(ninputs, noutputs)

	## STEP 3: Implement softmax_forw and softmax_cost
	#  softmax_forw function takes W, b, X, and Y
	#  calculates predicted probabilities
	#
	#  softmax_cost function obtains probabilites by calling softmax_forw
	#  then calculates soft loss,
	#  gradient of W and gradient of b

	## STEP 4: Gradient checking
	#
	#  As with any learning algorithm, you should always check that your
	#  gradients are correct before learning the parameters.


	debug = true #Turn this parameter off, after gradient checking passed

	if debug
		grad_check(W, b, xtrn[:, 1:100], ytrn[:, 1:100])
	end

	#Training parameters
	lr = 0.15
	epochs = 100

	## STEP 5: Implement training
	#  Complete the train function
	#  It takes model parameters and the data
	#  Trains the model over minibatches
	#  For each minibatch, cost and gradients are calculated then model parameters updated
	#  train function returns average cost
	#  implementation tip: you may want to use copy! or axpy! functions when updating parameters

	for i=1:epochs
		cost = train(W, b, xtrn, ytrn, lr)

		ypred = softmax_forw(W, b, xtrn)
		trnacc = accuracy(ytrn, ypred)

		ypred = softmax_forw(W, b, xtst)
		tstacc = accuracy(ytst, ypred)

		@printf("epoch: %d softloss: %g trn accuracy: %g tst accuracy: %g\n", i, cost, trnacc, tstacc)
	end

end


function init_params(ninputs, noutputs)
	#takes number of inputs and number of outputs(number of classes)
	#returns randomly generated W and b (must be zeros vector) params of softmax
	#W matrix must be drawn from a gaussian distribution (mean=0, std=0.001)
	#start of step 2
	#YOUR CODE HERE
	W = randn(noutputs,ninputs)*0.001
	b = zeros(noutputs,1)

	return W, b


	#end of step 2
end

function softmax_cost(W, b, X, Y)
	#takes W, b paremeters, X and Y (correct labels)
	#calculates soft loss, gradient of W and gradient of b
	#W and b are model parameters
	#W: (10 x 784)
	#b: (10 x 1)
	#X: (784 x m) m: number of instances
	#Y: (10 x m)
	#
	#returned gradients must have same sizes with W and b

	#start of step 3
	pi = softmax_forw(W,b,X)
	m = size(X,2)

	gradW = ((pi-Y) * transpose(X)) ./ m
	gradB = sum((pi-Y),2) ./ m
	negativell = Y .* log(pi)
	cost = -1*sum(negativell) ./ m
	return cost,gradW,gradB
	#YOUR CODE HERE

	#end of step 3
end

function softmax_forw(W, b, X)
	#applies affine transformation and softmax function
	#returns predicted probabilities
	#W and b are model parameters
	#W: (10 x 784)
	#b: (10 x 1)
	#X: (784 x m) m: number of instances
	#
	#Returned probabilities variable must be a matrix with size (10 x m)

	###

	#YOUR CODE HERE

	y = W * X .+ b
	p = copy(y);
	for i = 1 : size(X,2)
		p[:,i] = exp(y[:,i]) ./ sum(exp(y[:,i]))
	end
	return p
	###
end

function grad_check(W, b, X, Y)
	#W and b are model parameters
	#W: (10 x 784)
	#b: (10 x 1)
	#X: (784 x m) m: number of instances
	#Y: (10 x m)

	function numeric_gradient()
		epsilon = 0.0001

		gw = zeros(size(W))
		gb = zeros(size(b))

		#start of step 4



		#YOUR CODE HERE
		for i = 1 : size(W,1)
			for j = 1 : size(W,2)
				W[i,j] += epsilon;
				cost1,_,_= softmax_cost(W,b,X,Y)
				W[i,j] -= 2epsilon
				cost2,_,_ = softmax_cost(W,b,X,Y)
				gw[i,j] = (cost1-cost2)/2epsilon
				W[i,j] += epsilon
			end
		end

		for k = 1 : size(b,1)
			b[k] += epsilon;
			cost1,_,_= softmax_cost(W,b,X,Y)
			b[k] -= 2epsilon;
			cost2,_,_ = softmax_cost(W,b,X,Y)
			gb[k] = (cost1-cost2)/2epsilon
			b[k] += 2epsilon;
		end
		#end of step 4

		return gw, gb
	end

	cost4,gradW,gradB = softmax_cost(W, b, X, Y)
	gw, gb = numeric_gradient()

	diff = sqrt(mean((gradW - gw) .^ 2) + mean((gradB - gb) .^ 2))
	println("Diff: $diff")
	if diff < 1e-5
		println("Gradient Checking Passed")
	else
		println("Gradient Checking Failed!")
		println("Diff must be < 1e-5")
	end

end

function train(W, b, X, Y, lr=0.15)
	#W and b are model parameters
	#W: (10 x 784)
	#b: (10 x 1)
	#X: (784 x m) m: number of instances
	#Y: (10 x m)

	batchsize = 100

	#start of step 5
	#YOUR CODE HERE
	data = minibatch(X,Y,batchsize);
	meancost = 0.0
	numberofbatches = 0
	for (x,y) in data
			cost,gradW,gradB = softmax_cost(W, b,x,y)
			copy!(W,W-gradW*lr);
			copy!(b,b-gradB*lr);
			meancost = meancost + cost
			numberofbatches += 1
	end
		  meancost = meancost/numberofbatches
			return meancost
	#end of step 5
end

function minibatch(x, y, batchsize)
    data = Any[]
    for i=1:batchsize:size(x,2)
        j=min(i+batchsize-1,size(x,2))
        push!(data, (x[:,i:j], y[:,i:j]))
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

main()

#An example experiment log:
#===========================
Diff: 5.896954939041637e-10
Gradient Checking Passed
epoch: 1 softloss: 2.16192 trn accuracy: 0.788017 tst accuracy: 0.8025
epoch: 2 softloss: 0.932886 trn accuracy: 0.832683 tst accuracy: 0.8416
epoch: 3 softloss: 0.754694 trn accuracy: 0.852767 tst accuracy: 0.8573
epoch: 4 softloss: 0.661364 trn accuracy: 0.864283 tst accuracy: 0.8678
epoch: 5 softloss: 0.601667 trn accuracy: 0.871433 tst accuracy: 0.8749
epoch: 6 softloss: 0.559535 trn accuracy: 0.877433 tst accuracy: 0.8794
epoch: 7 softloss: 0.527818 trn accuracy: 0.882217 tst accuracy: 0.8824
epoch: 8 softloss: 0.502834 trn accuracy: 0.885633 tst accuracy: 0.8851
epoch: 9 softloss: 0.482503 trn accuracy: 0.8887 tst accuracy: 0.8868
epoch: 10 softloss: 0.465547 trn accuracy: 0.890767 tst accuracy: 0.8889
epoch: 11 softloss: 0.451121 trn accuracy: 0.8929 tst accuracy: 0.8899
epoch: 12 softloss: 0.438644 trn accuracy: 0.895 tst accuracy: 0.8914
epoch: 13 softloss: 0.427704 trn accuracy: 0.8968 tst accuracy: 0.8926
epoch: 14 softloss: 0.418002 trn accuracy: 0.89815 tst accuracy: 0.893
epoch: 15 softloss: 0.409315 trn accuracy: 0.899583 tst accuracy: 0.8939
epoch: 16 softloss: 0.401474 trn accuracy: 0.9007 tst accuracy: 0.895
epoch: 17 softloss: 0.394345 trn accuracy: 0.902117 tst accuracy: 0.8965
epoch: 18 softloss: 0.387824 trn accuracy: 0.903017 tst accuracy: 0.8982
epoch: 19 softloss: 0.381826 trn accuracy: 0.90405 tst accuracy: 0.899
epoch: 20 softloss: 0.376283 trn accuracy: 0.9049 tst accuracy: 0.9
epoch: 21 softloss: 0.371138 trn accuracy: 0.90575 tst accuracy: 0.9011
epoch: 22 softloss: 0.366347 trn accuracy: 0.906617 tst accuracy: 0.9015
epoch: 23 softloss: 0.361868 trn accuracy: 0.907417 tst accuracy: 0.9022
epoch: 24 softloss: 0.357671 trn accuracy: 0.908117 tst accuracy: 0.9029
epoch: 25 softloss: 0.353726 trn accuracy: 0.9088 tst accuracy: 0.9037
epoch: 26 softloss: 0.350009 trn accuracy: 0.909783 tst accuracy: 0.9041
epoch: 27 softloss: 0.346501 trn accuracy: 0.910567 tst accuracy: 0.9049
epoch: 28 softloss: 0.343182 trn accuracy: 0.911067 tst accuracy: 0.9052
epoch: 29 softloss: 0.340038 trn accuracy: 0.911833 tst accuracy: 0.9055
epoch: 30 softloss: 0.337053 trn accuracy: 0.912517 tst accuracy: 0.9065
============================#
