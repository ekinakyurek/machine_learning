##Ekin Akyrurek
##Machine Learning LAB#1
##ID:31459
#Exercise1
using Knet
file = download("https://archive.ics.uci.edu/ml/machine-learning-databases/housing/housing.data")
data = readdlm(file)

#Exercise2
x = data[:,1:13]
y = data[:,14:14]

#Exercise3
x = x .- mean(x,2) ./ std(x,2);


### I didn't normalize Ys because I assume It also didn't be done in the PDF.
#y = (y .- mean(y))/std(y)

#Exercise4
indexes = shuffle(collect(1:size(x,1)))
xtrn = x[indexes[1:400],:]'
ytrn = y[indexes[1:400],:]'

xtst = x[indexes[401:end],:]'
ytst = y[indexes[401:end],:]'

#Excercise5
w = randn(1,size(xtrn,1)) * 0.1
#display(w)

#Exercise6
function predict(w,x)
  return w*x
end

ypred = predict(w,xtrn)
#println("ypred: $ypred")

#Exercise7
function loss(w,x,y)
  return sumabs2(predict(w,x)-y)./(2length(y))
end

average_loss_trn = loss(w,xtrn,ytrn)
println("average_loss: $average_loss_trn")

#Exercise9

out = sum( abs(predict(w,xtrn)-ytrn) .< sqrt(average_loss_trn) )
