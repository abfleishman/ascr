#' Extract ascr model coefficients
#'
#' Extracts estimated and derived parameters from a model fitted using
#' \link{fit.ascr}.
#'
#' @param object A fitted model from \link[ascr]{fit.ascr}.
#' @param pars A character vector containing either parameter names,
#'     or a subset of \code{"all"}, \code{"derived"}, \code{"fitted"},
#'     and \code{"linked"}; \code{"fitted"} corresponds to the
#'     parameters of interest, \code{"derived"} corresponds to
#'     quantities that are functions of these parameters (e.g., the
#'     effective survey area or animal density from an acoustic
#'     survey), and \code{"linked"} corresponds to the parameters AD
#'     Model Builder has maximised the likelihood over.
#' @param ... Other parameters (for S3 generic compatibility).
#'
#' @examples
#' coef(example.data$fits$simple.hn)
#' coef(example.data$fits$simple.hn, pars = "all")
#' coef(example.data$fits$simple.hn, pars = "derived")
#'
#' @export
coef.ascr <- function(object, pars = "fitted", ...){
    if ("all" %in% pars){
        pars <- c("fitted", "derived", "linked")
    }
    if (any(pars == "esa")){
        pars <- pars[-which(pars == "esa")]
        pars <- c(pars, paste("esa", 1:object$n.sessions, sep = "."))
    }
    par.names <- names(object$coefficients)
    if (!all(pars %in% c("fitted", "derived", "linked", "esa", par.names))){
        stop("Argument 'pars' must either contain a vector of parameter names, or a subset of \"fitted\", \"derived\", \"linked\", and \"all\".")
    }
    if (any(c("fitted", "derived", "linked") %in% pars)){
        which.linked <- grep("_link", par.names)
        linked <- object$coefficients[which.linked]
        which.derived <- which(substr(par.names, 1, 3) == "esa" | par.names == "Da")
        derived <- object$coefficients[which.derived]
        fitted <- object$coefficients[-c(which.linked, which.derived)]
        out <- mget(pars)
        names(out) <- NULL
        out <- c(out, recursive = TRUE)
        if (!object$fit.ihd){
            out <- out[c("D", names(out)[!(names(out) %in% c("D.(Intercept)", "D"))])]
        }
    } else {
        out <- object$coefficients[pars]
    }
    out
}

#' @rdname coef.ascr
#'
#' @param correct.bias Logical, if \code{TRUE}, estimated biases are
#'     subtracted from estimated parameter values.
#'
#' @export
coef.ascr.boot <- function(object, pars = "fitted",
                           correct.bias = FALSE, ...){
    out <- coef.ascr(object, pars)
    if (correct.bias){
        out <- out - get.bias(object, pars)
    }
    out
}
#' Extract the variance-covariance matrix from an ascr model
#' object
#'
#' Extracts the variance-covariance matrix for parameters in a model
#' fitted using \link[ascr]{fit.ascr}.
#'
#' @inheritParams coef.ascr
#'
#' @examples
#' vcov(example.data$fits$simple.hn)
#' vcov(example.data$fits$simple.hn, pars = "all")
#' vcov(example.data$fits$simple.hn, pars = "derived")
#'
#' @export
vcov.ascr <- function(object, pars = "fitted", ...){
    if ("all" %in% pars){
        pars <- c("fitted", "derived", "linked")
    }
    if (any(pars == "esa")){
        pars <- pars[-which(pars == "esa")]
        pars <- c(pars, paste("esa", 1:object$n.sessions, sep = "."))
    }
    par.names <- names(object$coefficients)
    if (!all(pars %in% c("fitted", "derived", "linked", "esa", par.names))){
        stop("Argument 'pars' must either contain a vector of parameter names, or a subset of \"fitted\", \"derived\", \"linked\", and \"all\".")
    }
    if (any(c("fitted", "derived", "linked") %in% pars)){
        which.linked <- grep("_link", par.names)
        which.derived <- which(substr(par.names, 1, 3) == "esa" | par.names == "Da")
        which.fitted <- (1:length(par.names))[-c(which.linked, which.derived)]
        keep <- NULL
        if ("fitted" %in% pars){
            keep <- c(keep, which.fitted)
        }
        if ("derived" %in% pars){
            keep <- c(keep, which.derived)
        }
        if ("linked" %in% pars){
            keep <- c(keep, which.linked)
        }
    } else {
        keep <- pars
    }
    if (!object$fit.ihd){
        keep <- keep[par.names[keep] != "D.(Intercept)"]
        keep <- keep[c(which(par.names[keep] == "D"), which(par.names[keep] != "D"))]
    }
    object$vcov[keep, keep, drop = FALSE]
}

#' Extract the variance-covariance matrix from a bootstrapped ascr
#' model object
#'
#' Extracts the variance-covariance matrix for parameters in a model
#' fitted using \link[ascr]{fit.ascr}, with a bootstrap procedure
#' carried out using \link[ascr]{boot.ascr}.
#'
#' @inheritParams coef.ascr
#'
#' @export
vcov.ascr.boot <- function(object, pars = "fitted", ...){
    if ("all" %in% pars){
        pars <- c("fitted", "derived", "linked")
    }
    if (any(pars == "esa")){
        pars <- pars[-which(pars == "esa")]
        pars <- c(pars, paste("esa", 1:object$n.sessions, sep = "."))
    }
    par.names <- names(object$coefficients)
    if (!all(pars %in% c("fitted", "derived", "linked", "esa", par.names))){
        stop("Argument 'pars' must either contain a vector of parameter names, or a subset of \"fitted\", \"derived\", \"linked\", and \"all\".")
    }
    if (any(c("fitted", "derived", "linked") %in% pars)){
        which.linked <- grep("_link", par.names)
        which.derived <- which(substr(par.names, 1, 3) == "esa" | par.names == "Da")
        which.fitted <- (1:length(par.names))[-c(which.linked, which.derived)]
        keep <- NULL
        if ("fitted" %in% pars){
            keep <- c(keep, which.fitted)
        }
        if ("derived" %in% pars){
            keep <- c(keep, which.derived)
        }
        if ("linked" %in% pars){
            keep <- c(keep, which.linked)
        }
    } else {
        keep <- pars
    }
    if (!object$fit.ihd){
        keep <- keep[par.names[keep] != "D.(Intercept)"]
        keep <- keep[c(which(par.names[keep] == "D"), which(par.names[keep] != "D"))]
    }
    object$boot$vcov[keep, keep, drop = FALSE]
}

#' Extract standard errors from an ascr model fit
#'
#' Extracts standard errors for estimated and derived parameters from
#' a model fitted using \link[ascr]{fit.ascr}.
#'
#' @inheritParams coef.ascr
#'
#' @examples
#' stdEr(example.data$fits$simple.hn)
#' stdEr(example.data$fits$simple.hn, pars = "all")
#' stdEr(example.data$fits$simple.hn, pars = "derived")
#'
#' @export
stdEr.ascr <- function(object, pars = "fitted", ...){
    if ("all" %in% pars){
        pars <- c("fitted", "derived", "linked")
    }
    if (any(pars == "esa")){
        pars <- pars[-which(pars == "esa")]
        pars <- c(pars, paste("esa", 1:object$n.sessions, sep = "."))
    }
    par.names <- names(object$coefficients)
    if (!all(pars %in% c("fitted", "derived", "linked", "esa", par.names))){
        stop("Argument 'pars' must either contain a vector of parameter names, or a subset of \"fitted\", \"derived\", \"linked\", and \"all\".")
    }
    if (any(c("fitted", "derived", "linked") %in% pars)){
        which.linked <- grep("_link", par.names)
        linked <- object$se[which.linked]
        which.derived <- which(substr(par.names, 1, 3) == "esa" | par.names == "Da")
        derived <- object$se[which.derived]
        fitted <- object$se[-c(which.linked, which.derived)]
        out <- mget(pars)
        names(out) <- NULL
        out <- c(out, recursive = TRUE)
        if (!object$fit.ihd){
            out <- out[c("D", names(out)[!(names(out) %in% c("D.(Intercept)", "D"))])]
        }
    } else {
        out <- object$se[pars]
    }
    out
}

#' Extract standard errors from a bootstrapped ascr model object
#'
#' Extracts standard errors for parameters of a model fitted using
#' \link[ascr]{fit.ascr}, with a bootstrap procedure carried out
#' using \link[ascr]{boot.ascr}.
#'
#' @param mce Logical, if \code{TRUE} Monte Carlo error for the
#'     standard errors is also returned.
#' @inheritParams coef.ascr
#'
#' @export
stdEr.ascr.boot <- function(object, pars = "fitted", mce = FALSE, ...){
    if ("all" %in% pars){
        pars <- c("fitted", "derived", "linked")
    }
    if (any(pars == "esa")){
        pars <- pars[-which(pars == "esa")]
        pars <- c(pars, paste("esa", 1:object$n.sessions, sep = "."))
    }
    par.names <- names(object$coefficients)
    if (!all(pars %in% c("fitted", "derived", "linked", "esa", par.names))){
        stop("Argument 'pars' must either contain a vector of parameter names, or a subset of \"fitted\", \"derived\", \"linked\", and \"all\".")
    }
    mces <- get.mce(object, estimate = "se")
    if (any(c("fitted", "derived", "linked") %in% pars)){
        which.linked <- grep("_link", par.names)
        linked <- object$boot$se[which.linked]
        which.derived <- which(substr(par.names, 1, 3) == "esa" | par.names == "Da")
        derived <- object$boot$se[which.derived]
        fitted <- object$boot$se[-c(which.linked, which.derived)]
        out <- mget(pars)
        names(out) <- NULL
        out <- c(out, recursive = TRUE)
        if (!object$fit.ihd){
            out <- out[c("D", names(out)[!(names(out) %in% c("D.(Intercept)", "D"))])]
        }
    } else {
        out <- object$boot$se[pars]
    }
    if (mce){
        out.vec <- out
        out <- cbind(out.vec, mces[names(out)])
        rownames(out) <- names(out.vec)
        colnames(out) <- c("Std. Error", "MCE")
    }
    out
}

#' Extract AIC from an ascr model object
#'
#' Extracts the AIC from an ascr model object.
#'
#' If the model is based on an acoustic survey where there are
#' multiple calls per individual, then AIC should not be used for
#' model selection. This function therefore returns NA in this case.
#'
#' @inheritParams coef.ascr
#' @inheritParams stats::AIC
#'
#' @export
AIC.ascr <- function(object, ..., k = 2){
    if (object$fit.freqs){
        message("NOTE: Use of AIC for this model relies on independence between locations of calls from the same animal, which may not be appropriate")
    }
    deviance(object) + k*length(coef(object))
}

#' Summarising ascr model fits
#'
#' Provides a useful summary of the model fit.
#'
#' @inheritParams coef.ascr
#'
#' @export
summary.ascr <- function(object, ...){
    coefs <- coef(object, "fitted")
    derived <- coef(object, "derived")
    coefs.se <- stdEr(object, "fitted")
    derived.se <- stdEr(object, "derived")
    infotypes <- object$infotypes
    detfn <- object$args$detfn
    n.sessions <- object$n.sessions
    out <- list(coefs = coefs, derived = derived, coefs.se = coefs.se,
                derived.se = derived.se, infotypes = infotypes,
                detfn = detfn, n.sessions = n.sessions)
    class(out) <- c("summary.ascr", class(out))
    out
}

#' @export
print.summary.ascr <- function(x, ...){
    n.coefs <- length(x$coefs)
    n.derived <- length(x$derived)
    mat <- matrix(0, nrow = n.coefs + n.derived + 1, ncol = 2)
    mat[1:n.coefs, 1] <- c(x$coefs)
    mat[1:n.coefs, 2] <- c(x$coefs.se)
    mat[n.coefs + 1, ] <- NA
    mat[(n.coefs + 2):(n.coefs + n.derived + 1), ] <- c(x$derived, x$derived.se)
    rownames(mat) <- c(names(x$coefs), "---", names(x$derived))
    colnames(mat) <- c("Estimate", "Std. Error")
    detfn <- c(hn = "Halfnormal", hhn = "Hazard halfnormal", hr = "Hazard rate", th = "Threshold",
               lth = "Log-link threshold", ss = "Signal strength")[x$detfn]
    infotypes <- c(bearing = "Bearings", dist = "Distances", ss = "Signal strengths",
                   toa = "Times of arrival", mrds = "Exact locations")[x$infotypes]
    cat("Detection function:", detfn, "\n")
    cat("Information types: ")
    cat(infotypes, sep = ", ")
    cat("\n", "\n", "Parameters:", "\n")
    printCoefmat(mat, na.print = "")
}

#' Confidence intervals for ascr model parameters
#'
#' Computes confidence intervals for one or more parameters estimated
#' in an ascr model object.
#'
#' Options for the argument \code{method} are as follows:
#' \code{"default"} for intervals based on a normal approximation
#' using the calculated standard errors (for objects of class
#' \code{ascr.boot}, these standard errors are calculated from the
#' bootstrap procedure); \code{"default.bc"} is a bias-corrected
#' version of \code{default}, whereby the estimated bias is subtracted
#' from each confidence limit; \code{"basic"} for the so-called
#' "basic" bootstrap method; and \code{"percentile"} for intervals
#' calculated using the bootstrap percentile method (the latter three
#' are only available for objects of class \code{ascr.boot}; see
#' Davison & Hinkley, 1997, for details).
#'
#' For method \code{"default"} with objects of class
#' \code{ascr.boot}, the appropriateness of the normal
#' approximation can be evaluated by setting \code{qqnorm} to
#' \code{TRUE}. If this indicates a poor fit, set \code{linked} to
#' \code{TRUE} and evaluate the QQ plot to see if this yields an
#' improvement (see Davison & Hinkley, 1997, pp. 194, for details).
#'
#' @references Davison, A. C., and Hinkley, D. V. (1997)
#' \emph{Bootstrap methods and their application}. Cambridge:
#' Cambridge University Press.
#'
#' @param parm A character vector containing either parameter names,
#' or a subset of \code{"all"}, \code{"derived"}, \code{"fitted"}, and
#' \code{"linked"}; \code{"fitted"} corresponds to the parameters of
#' interest, \code{"derived"} corresponds to quantities that are
#' functions of these parameters (e.g., the effective survey area or
#' animal density from an acoustic survey), and \code{"linked"}
#' corresponds to the parameters AD Model Builder has maximised the
#' likelihood over.
#' @param linked Logical, if \code{TRUE}, intervals for fitted
#' parameters are calculated on their link scales, then transformed
#' back onto their "real" scales.
#' @inheritParams coef.ascr
#' @inheritParams stats::confint
#'
#' @export
confint.ascr <- function(object, parm = "fitted", level = 0.95, linked = FALSE, ...){
    if (!object$args$hess){
        stop("Standard errors not calculated; use boot.ascr() or refit with 'hess = TRUE', if appropriate.")
    }
    calc.cis(object, parm, level, method = "default", linked, qqplot = FALSE,
             boot = FALSE, ask = FALSE, ...)
}

#' @param method A character string specifying the method used to
#' calculate the confidence intervals. See 'Details' below.
#' @param qqplot Logical, if \code{TRUE} and \code{method} is
#' \code{"default"} then a normal QQ plot is plotted. The default
#' method is based on a normal approximation; this plot tests its
#' validity.
#' @param ask Logical, if \code{TRUE}, hitting return will show the
#' next plot.
#'
#' @rdname confint.ascr
#'
#' @export
confint.ascr.boot <- function(object, parm = "fitted", level = 0.95, method = "default",
                                  linked = FALSE, qqplot = FALSE, ask = TRUE, ...){
    calc.cis(object, parm, level, method, linked, qqplot, boot = TRUE, ask, ...)
}

calc.cis <- function(object, parm, level, method, linked, qqplot, boot, ask, ...){
    if (any(c("all", "derived", "fitted") %in% parm)){
        parm <- names(coef(object, pars = parm))
    }
    if (linked){
        fitted.names <- names(coef(object, "fitted")[parm])
        fitted.names <- fitted.names[fitted.names != "mu.rates"]
        linked.names <- paste(fitted.names, "_link", sep = "")
        linked.names[linked.names == "D_link"] <- "D.(Intercept)_link"
        link.parm <- linked.names[!(linked.names %in% parm)]
        all.parm <- c(parm, link.parm)
    } else {
        all.parm <- parm
    }
    if (any(all.parm == "esa")){
        all.parm <- all.parm[-which(all.parm == "esa")]
        all.parm <- c(all.parm, paste("esa", 1:object$n.sessions, sep = "."))
    }
    if (method == "default" | method == "default.bc"){
        mat <- cbind(coef(object, pars = "all")[all.parm],
                     stdEr(object, pars = "all")[all.parm])
        FUN.default <- function(x, level){
            x[1] + qnorm((1 - level)/2)*c(1, -1)*x[2]
        }
        out <- t(apply(mat, 1, FUN.default, level = level))
        if (method == "default.bc"){
            out <- out - get.bias(object, parm)
        }
        if (qqplot & boot){
            opar <- par(ask = ask)
            for (i in parm){
                if (linked){
                    if (i %in% fitted.names){
                        j <- linked.names[fitted.names == i]
                    }
                } else {
                    j <- i
                }
                qqnorm(object$boot$boots[, j], main = i)
                abline(mean(object$boot$boots[, j], na.rm = TRUE),
                       sd(object$boot$boots[, j], na.rm = TRUE))
            }
            par(opar)
        }
    } else if (method == "basic"){
        qs <- t(apply(object$boot$boots[, all.parm, drop = FALSE], 2, quantile,
                      probs = c((1 - level)/2, 1 - (1 - level)/2),
                      na.rm = TRUE))
        mat <- cbind(coef(object, pars = "all")[all.parm], qs)
        FUN.basic <- function(x){
            2*x[1] - c(x[3], x[2])
        }
        out <- t(apply(mat, 1, FUN.basic))
    } else if (method == "percentile"){
        out <- t(apply(object$boot$boots[, all.parm, drop = FALSE], 2, quantile,
                       probs = c((1 - level)/2, 1 - (1 - level)/2),
                       na.rm = TRUE))
    }
    if (linked){
        for (i in fitted.names){
            linked.name <- paste(i, "_link", sep = "")
            if (linked.name == "D_link"){
                linked.name <- "D.(Intercept)_link"
                object$par.unlinks[[i]] <- exp
            }
            out[i, ] <- object$par.unlinks[[i]](out[linked.name, ])
        }
        out <- out[parm, , drop = FALSE]
    }
    percs <- c(100*(1 - level)/2, 100*(1 - (1 - level)/2))
    colnames(out) <- paste(round(percs, 2), "%")
    out
}

#' Extract density estimates given a set of covariate values
#'
#' Extracts density estimates from a set of supplied parameter values.
#'
#' @param object A fitted model from \link[ascr]{fit.ascr}.
#' @param newdata An optional data frame in which to look for
#'     variables with which to estimate density. If omitted, the
#'     function will return the estimated densities at the mask
#'     points.
#' @param se.fit A switch indicating if standard errors are
#'     required. At present, this will only work if \code{newdata} is
#'     also provided.
#' @param use.log If \code{TRUE}, density estimates and standard
#'     errors (if calculated) are provided on the log scale.
#' @param set.zero Indices for effects to ignore. For example,
#'     \code{set.zero = c(1, 3)} will set the first (probably an
#'     intercept) and third terms in the linear predictor to zero when
#'     calculating the predictions.
#' @param ... Other parameters (for S3 generic compatibility).
#'
#' @export
predict.ascr <- function(object, newdata = NULL, se.fit = FALSE,
                         use.log = FALSE, set.zero = NULL, ...){
    if (is.null(newdata)){
        out <- object$D.mask
    } else {
        ## Filling in x and y if required.
        if (!any(colnames(newdata) == "y")){
            newdata <- data.frame(y = rep(NA, nrow(newdata)), newdata)
        }
        if (!any(colnames(newdata) == "x")){
            newdata <- data.frame(x = rep(NA, nrow(newdata)), newdata)
        }
        ## Scaling data.
        newdata.scaled <- object$scale.covs(newdata)
        ## Creating model matrix.
        mm <- predict(gam(G = object$fgam), newdata = newdata.scaled, type = "lpmatrix")
        if (!is.null(set.zero)){
            mm[, set.zero] <- 0
        }
        ## Calculated estimated density.
        out <- as.vector(exp(mm %*% get.par(object, object$D.betapars)))
        if (use.log){
            out <- log(out)
        }
        if (se.fit){
            ## Gotta implement the delta method.
            n.predict <- length(out)
            n.betapars <- length(object$D.betapars)
            est.vcov <- vcov(object)
            est.vcov <- est.vcov[rownames(est.vcov) != "mu.rates", colnames(est.vcov) != "mu.rates"]
            n.par <- nrow(est.vcov)
            jacobian <- matrix(0, nrow = n.predict, ncol = n.par)
            colnames(jacobian) <- colnames(est.vcov)
            for (i in 1:ncol(jacobian)){
                if (colnames(jacobian)[i] %in% object$D.betapars){
                    if (use.log){
                        jacobian[, i] <- mm[, which(colnames(jacobian)[i] == object$D.betapars)]
                    } else {
                        jacobian[, i] <- mm[, which(colnames(jacobian)[i] == object$D.betapars)]*out
                    }
                } else {
                    jacobian[, i] <- 0
                }
            }
            se <- sqrt(diag(jacobian %*% est.vcov %*% t(jacobian)))
            out <- cbind(out, se)
            colnames(out) <- c("predict", "se")
        }
    }
    out
}

