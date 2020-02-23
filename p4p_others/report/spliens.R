# plot bsplines

par(mfrow = c(2,1), mar = c(2,2,2,2))

x = seq(0,1, length = 100)
x1 = seq(1,2, length = 100)
x2 = seq(2,3, length = 100)
x3 = seq(3,4, length = 100)
cy = function(x) (x^3)/6
cy1 = function(x) (x * x * (3 * x - 6) + 4) / 6
cy2 = function(x) (x * (x * (-3 * x + 3) + 3) + 1) / 6
cy3 = function(x) ((1-x)^3) / 6

plot(x,cy(x)*1.5, type ='l', 
     xlim = c(0,4), ylim = c(0,1.2), 
     axes = FALSE, xaxs = 'i', 
     xlab = '', ylab = '', main = 'Cubic B-Spline basis')
lines(x,cy1(x), col = 'darkgreen')
lines(x,cy2(x), col = 'darkblue')
lines(x,cy3(x), col = 'seagreen')
lines(x1,cy(x), col = 'purple')
lines(x1,cy1(x), col = 'darkblue')
lines(x1,cy2(x))
lines(x1,cy3(x), col = 'darkgreen')
lines(x2,cy1(x))
lines(x2,cy2(x), col = 'purple')
lines(x2,cy3(x), col = 'darkblue')
lines(x2,cy(x),col = 'darkred')
lines(x3,cy(x), col = 'orange')
lines(x3,cy1(x), col = 'purple')
lines(x3,cy2(x), col = 'darkred')
lines(x3,cy3(x))

axis(1, las = 1)
box()
abline(v = 1:3)
legend('topright', legend=c('control point', 'knots'), pch = c(4, NA), lty = c(NA, 1))

points(0:4, rep(0,5), pch = 4, lwd = 4, col = c('darkgreen', 'darkblue', 'black', 'purple', 'darkred'))

xneg2 = seq(-2,-1, length = 100)
xneg1 = seq(-1,0, length = 100)
x = seq(0,1, length = 100)
x1 = seq(1,2, length = 100)
x2 = seq(2,3, length = 100)
x3 = seq(3,4, length = 100)
x4 = seq(4,5, length = 100)

qy = function(x) (x^2)/2
qy1 = function(x) (2*x*(1-x) + 1)/2
qy2 = function(x) ((1-x)^2) / 2

plot(x,qy(x), type ='l', 
     xlim = c(-2,5), ylim = c(0,1), 
     axes = FALSE, xaxs = 'i', yaxs = 'i', 
     xlab = '', ylab = '')

lines(xneg2, qy(x), col = 'darkblue')
lines(xneg1, qy1(x), col = 'darkblue')
lines(xneg1, qy(x), col = 'darkgreen')
lines(x,qy1(x), col = 'darkgreen')
lines(x,qy2(x), col = 'darkblue')
lines(x1,qy(x), col = 'purple')
lines(x1,qy1(x))
lines(x1,qy2(x), col = 'darkgreen')
lines(x2,qy1(x), col = 'purple')
lines(x2,qy2(x))
lines(x2,qy(x), col = 'orange')
lines(x3,qy1(x), col = 'orange')
lines(x4,qy2(x), col = 'orange')
lines(x3,qy2(x), col = 'purple')


axis(1, las = 1)
box()
abline(v = c(0,3), lty = 2)
points(0.5:2.5, rep(0,3), pch = 4, lwd = 4, col = c('darkgreen', 'black', 'purple'))

png("2dspline.png", width = 6, height = 4, units = 'in', res = 300)

plot(x,qy(x), type ='l', 
     xlim = c(-2,5), ylim = c(0,1.2), 
     axes = FALSE, xaxs = 'i', yaxs = 'i', 
     xlab = '', ylab = '')

lines(xneg2, qy(x), col = 'darkblue')
lines(xneg1, qy1(x), col = 'darkblue')
lines(xneg1, qy(x), col = 'darkgreen')
lines(x,qy1(x), col = 'darkgreen')
lines(x,qy2(x), col = 'darkblue')
lines(x1,qy(x), col = 'purple')
lines(x1,qy1(x))
lines(x1,qy2(x), col = 'darkgreen')
lines(x2,qy1(x), col = 'purple')
lines(x2,qy2(x))
lines(x2,qy(x), col = 'orange')
lines(x3,qy1(x), col = 'orange')
lines(x4,qy2(x), col = 'orange')
lines(x3,qy2(x), col = 'purple')
abline(v = c(0,3), lty = 2)

dev.off()

png("presba.png", width = 6, height = 4, units = 'in', res = 300)

plot(x,qy(x), type ='l', 
     xlim = c(0,3), ylim = c(0,0.8), 
     axes = FALSE, xaxs = 'i', 
     xlab = '', ylab = '', main = 'Quadratic B-Spline basis')
lines(x1,qy1(x)) 
lines(x2,qy2(x))
abline(v = 1:3, lty = 2)
legend('topright', legend=c('Control Point', expression(paste('Knots (', xi[k], ')'))), pch = c(4, NA), lty = c(NA, 2), cex = 0.8)
points(1.5,0,pch=4,lwd=4)
axis(1, las = 1)
axis(2, las = 1)
box()
dev.off()
