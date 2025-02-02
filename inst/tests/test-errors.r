context("Testing fit.ascr() errors")

test_that("error for missing bincapt", {
    test.capt <- example.data$capt["toa"]
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask),
                throws_error("The binary capture history must be provided as a component of 'capt'."))
})

test_that("error for non-matrix in capt object", {
    test.capt <- example.data$capt["bincapt"]
    test.capt$bearing <- 1:10
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask),
                throws_error("At least one component of 'capt' is not a matrix."))
})

test_that("error for mismatch in number of individuals or traps", {
    ## Testing error checking for equality in number of rows.
    test.capt <- example.data$capt[c("bincapt", "bearing", "dist")]
    test.capt$bearing <- test.capt$bearing[-1, ]
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask),
                throws_error("Components of 'capt' object within a session have different dimensions."))
    ## Testing error checking for equality in number of columns.
    test.capt <- example.data$capt[c("bincapt", "bearing", "dist")]
    test.capt$bearing <- test.capt$bincapt[, -1]
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask),
                throws_error("Components of 'capt' object within a session have different dimensions."))
    ## Testing error checking for matching in number of traps.
    test.capt <- example.data$capt["bincapt"]
    test.capt$bincapt <- test.capt$bincapt[, -1]
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask),
                throws_error("There must be a trap location for each column in the components of 'capt'."))
})

test_that("arguments are of the right type", {
    test.capt <- example.data$capt["bincapt"]
    ## Testing error checking for 'sv' type.
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask, sv = c(D = 1000, g0 = 1)),
                throws_error("The 'sv' argument must be 'NULL' or a list."))
    ## Testing error checking for 'bounds' type.
    bounds <- matrix(1:6, ncol = 2)
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask, bounds = bounds),
                throws_error("The 'bounds' argument must be 'NULL' or a list."))
    bounds <- list(D = 1000, g0 = c(0, 0.9))
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask, bounds = bounds),
                throws_error("Each component of 'bounds' must be a vector of length 2."))
    ## Testing error checking for 'fix' type.
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask, fix = c(D = 1000, g0 = 1)),
                throws_error("The 'fix' argument must be 'NULL' or a list."))
})

test_that("ss-related parameters set up correctly", {
    test.capt <- example.data$capt[c("bincapt", "ss")]
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask,
                         sv = list(b0.ss = 90, b1.ss = 4, sigma.ss = 10),
                         ss.opts = list(cutoff = 60, ss.link = "identity.link")),
                throws_error("Component 'ss.link' in 'ss.opts' must be \"identity\", \"log\", or \"spherical\"."))
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask,
                         sv = list(b0.ss = 90, b1.ss = 4, sigma.ss = 10),
                         fix = list(b2.ss = 0),
                         ss.opts = list(cutoff = 60), detfn = "hr"),
                gives_warning("Argument 'detfn' is being ignored as signal strength information is provided in 'capt'. A signal strength detection function has been fitted instead."))
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask,
                         sv = list(b0.ss = 90, b1.ss = 4, sigma.ss = 10)),
                throws_error("Argument 'ss.opts' is missing."))
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask,
                         sv = list(b0.ss = 90, b1.ss = 4, sigma.ss = 10),
                         ss.opts = list(ss.link = "log")),
                throws_error("The 'cutoff' component of 'ss.opts' must be specified."))

})

test_that("exe.type argument is correct", {
    test.capt <- example.data$capt["bincapt"]
    ## Testing error checking for 'sv' type.
    expect_that(fit.ascr(capt = test.capt, traps = example.data$traps,
                         mask = example.data$mask, optim.opts = list(exe.type = "diff")),
                throws_error("Argument 'exe.type' must be \"old\" or \"new\"."))
})

test_that("Extra components of 'sv' and 'fix' are removed", {
    test.capt <- example.data$capt["bincapt"]
    ## Testing warning checking 'sv' components.
    expect_that(test.fit <- fit.ascr(capt = test.capt, traps = example.data$traps,
                                     mask = example.data$mask, sv = list(z = 5, g0 = 1),
                                     fix = list(g0 = 1)),
                gives_warning("Some parameters listed in 'sv' are not being used. These are being removed."))
    expect_that(test.fit, equals(example.data$fits$simple.hn))
    ## Testing warning checking 'fix' components.
    expect_that(test.fit <- fit.ascr(capt = test.capt, traps = example.data$traps,
                                     mask = example.data$mask, fix = list(g0 = 1, foo = 0)),
                gives_warning("Some parameters listed in 'fix' are not being used. These are being removed."))
    expect_that(test.fit, equals(example.data$fits$simple.hn))
})

test_that("cue.rates and survey.length arguments set up correctly", {
    test.capt <- example.data$capt["bincapt"]
    expect_that(fit <- fit.ascr(capt = test.capt, traps = example.data$traps,
                    mask = example.data$mask, fix = list(g0 = 1),
                    cue.rates = c(9, 10, 11)),
                throws_error("The use of `cue.rates' without `survey.length' is no longer supported. Please provide `survey.length', and ensure `cue.rates' is measured in the same time units."))
})
