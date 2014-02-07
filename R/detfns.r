## Shortcut to get detection probability
calc.detfn <- function(d, detfn, pars){
    g <- get.detfn(detfn)
    g(d, pars)
}

## Returns a detection function.
get.detfn <- function(detfn){
    if (!(detfn %in% c("hn", "hr", "th", "lth", "ss", "log.ss"))){
        stop("Argument 'detfn' must be \"hn\", \"hr\", \"th\", \"lth\", \"ss\", or \"log.ss\"")
    }
    switch(detfn, hn = calc.hn, hr = calc.hr, th = calc.th,
           lth = calc.lth, ss = calc.ss, log.ss = calc.log.ss)
}

calc.hn <- function(d, pars){
    if (!identical(sort(names(pars)), c("g0", "sigma"))){
        stop("Argument 'pars' must have named components 'g0' and 'sigma'.")
    }
    g0 <- pars$g0
    sigma <- pars$sigma
    g0*exp(-(d^2/(2*sigma^2)))
}

calc.hr <- function(d, pars){
    if (!identical(sort(names(pars)), c("g0", "sigma", "z"))){
        stop("Argument 'pars' must have named components 'g0', 'sigma', and 'z'.")
    }
    g0 <- pars$g0
    sigma <- pars$sigma
    z <- pars$z
    g0*(1 - exp(-((d/sigma)^-z)))
}

calc.th <- function(d, pars){
    if (!identical(sort(names(pars)), c("scale", "shape"))){
        stop("Argument 'pars' must have named components 'scale' and 'shape'.")
    }
    scale <- pars$scale
    shape <- pars$shape
    0.5 - 0.5*erf(d/scale - shape)
}

calc.lth <- function(d, pars){
    if (!identical(sort(names(pars)), c("scale", "shape.1", "shape.2"))){
        stop("Argument 'pars' must have named components 'scale', 'shape.1', and 'shape.2'.")
    }
    scale <- pars$scale
    shape.1 <- pars$shape.1
    shape.2 <- pars$shape.2
    0.5 - 0.5*erf(shape.1 - exp(shape.2 - scale*d))
}

calc.ss <- function(d, pars){
    if (!identical(sort(names(pars)), c("b0.ss", "b1.ss", "cutoff", "sigma.ss"))){
        stop("Argument 'pars' must have named components 'b0.ss', 'b1.ss', 'sigma.ss', and 'cutoff'.")
    }
    b0.ss <- pars$b0.ss
    b1.ss <- pars$b1.ss
    sigma.ss <- pars$sigma.ss
    cutoff <- pars$cutoff
    1 - pnorm(cutoff, mean = b0.ss - b1.ss*d, sd = sigma.ss)
}

calc.log.ss <- function(d, pars){
    if (!identical(sort(names(pars)), c("b0.ss", "b1.ss", "cutoff", "sigma.ss"))){
        stop("Argument 'pars' must have named components 'b0.ss', 'b1.ss', 'sigma.ss', and 'cutoff'.")
    }
    b0.ss <- pars$b0.ss
    b1.ss <- pars$b1.ss
    sigma.ss <- pars$sigma.ss
    cutoff <- pars$cutoff
    1 - pnorm(cutoff, mean = exp(b0.ss - b1.ss*d), sd = sigma.ss)
}

#' Plotting a detection function.
#'
#' Plots an estimated detection function from a model fit generated by
#' \link[admbsecr]{admbsecr}.
#'
#' @param fit A fitted model from \link[admbsecr]{admbsecr}.
#' @param xlim A vector with two elements, giving the x-axis
#' limits. If \code{NULL}, this is set to the buffer of the mask.
#' @param ylim A vector with two elements, giving the y-axis limits.
#' @param main The main title.
#' @param xlab The x-axis label.
#' @param ylab The y-axis label.
#' @param add Logical, if \code{TRUE}, the estimated detection
#' function is added to an existing plot.
#' @param ... Further arguments to be passed to \link[graphics]{lines}.
#' @export
show.detfn <- function(fit, xlim = NULL, ylim = c(0, 1), main = NULL,
                       xlab = "Distance (m)", ylab = "Detection probability",
                       add = FALSE, ...){
    if (is.null(xlim)){
        xlim <- c(0, attr(fit$mask, "buffer"))
    }
    pars <- getpar(fit, fit$detpars, as.list = TRUE)
    dists <- seq(xlim[1], xlim[2], length.out = 1000)
    probs <- calc.detfn(dists, fit$detfn, pars)
    if (!add){
        plot.new()
        old.par <- par(xaxs = "i")
        plot.window(xlim = xlim, ylim = ylim)
        axis(1)
        axis(2)
        box()
        abline(h = c(0, 1), col = "lightgrey")
        title(main = main, xlab = xlab, ylab = ylab)
        par(old.par)
    }
    lines(dists, probs, ...)
}
