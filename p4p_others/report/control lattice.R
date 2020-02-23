par(mfrow = c(1,1), mar = c(2,2,4,2))
plot.new()
plot.window(xlim = c(0,3), ylim = c(0,3))
abline(h = 0:3)
abline(v = 0:3)
points(c(0.1,1.5,2.1,2.6),c(1.2,2.1,2.3,0.1))
points(rep(0:3,4), rep(0:3,each=4), pch=4, col ='blue', lwd = 2)
points(rep(0.5:2.5,3), rep(0.5:2.5,each = 3), pch =4, col = 'red', lwd = 2)
title(main = 'control lattice for b-splines surface')

legend('topright', legend = c('cubic control points', 'quadratic control points', 'knots' , 'observations'), pch = c(4,4,NA,1), lty = c(NA,NA,1,NA), col = c('blue', 'red', 1, 1))

png("Plot3.png", width = 6, height = 4, units = 'in', res = 300)

plot.new()
plot.window(xlim = c(0,3), ylim = c(0,3))
abline(h = 1:2, lty = 2)
abline(v = 1:2, lty = 2)
points(rep(0.5:2.5,3), rep(0.5:2.5,each = 3), pch =4, col = 'red', lwd = 2)
title('Control Lattice for B-splines Surface', cex = 10)
legend('topright', legend = c('Control points', expression(paste('Boundaries (', xi[kl], ')'))), pch = c(4,NA), lty = c(NA,2), col = c('red',1), cex = 0.8)
dev.off()


png("Plot3.png", width = 6, height = 4, units = 'in', res = 300)
par(mar = rep(0, 4), oma=c(4, 4, 4, 2), las=1)

layout(matrix( c(0,2,2,1,3,3,1,3,3),ncol=3), width = c(1,5), heights = c(1,4))

x = seq(0,1, length = 100)
x1 = seq(1,2, length = 100)
x2 = seq(2,3, length = 100)
x3 = seq(3,4, length = 100)
plot(x,qy(x), type ='l', 
     xlim = c(0,3), ylim = c(0,0.8), 
     axes = FALSE, xlab = '', ylab = '')
lines(x1,qy1(x)) 
lines(x2,qy2(x))
abline(v = 1:2, lty = 2)
qy = function(x) (x^2)/2
qy1 = function(x) (2*x*(1-x) + 1)/2
qy2 = function(x) ((1-x)^2) / 2
box()

legend('topright', legend = c('Control points', expression(paste('Boundaries (', xi[kl], ')'))), pch = c(4,NA), lty = c(NA,2), col = c('red',1), cex = 0.8)

plot(-qy(x),x, type ='l', 
     xlim = -c(0.8,0), ylim = c(0,3), 
     axes = FALSE, xlab = '', ylab = '')
lines(-qy1(x), x1) 
lines(-qy2(x), x2)
abline(h = 1:2, lty = 2)
box()

plot.new()
plot.window(xlim = c(0,3), ylim = c(0,3))
abline(h = 1:2, lty = 2)
abline(v = 1:2, lty = 2)
points(rep(0.5:2.5,3), rep(0.5:2.5,each = 3), pch =4, col = 'red', lwd = 2)

box()

title('Control Lattice for B-splines Surface', cex = 10, outer = TRUE)

dev.off()
