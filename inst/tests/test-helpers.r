context("Testing helper functions")

test_that("testing get.par", {
    ## All parameters estimated.
    expect_that(get.par(example.data$fits$simple.hr, "all"),
                is_identical_to(coef(example.data$fits$simple.hr, c("fitted", "derived"))))
    expect_that(get.par(example.data$fits$simple.hr, c("D", "esa")),
                is_identical_to(coef(example.data$fits$simple.hr, c("fitted", "derived"))[c(1, 5)]))
    ## Fixed parameter.
    expect_that(get.par(example.data$fits$simple.hn, "g0"), is_equivalent_to(1))
    expect_that(get.par(example.data$fits$simple.hn, c("sigma", "g0")),
                is_equivalent_to(c(coef(example.data$fits$simple.hn)[2], 1)))
    ## Supplementary parameters.
    expect_that(get.par(example.data$fits$bearing.hn, c("kappa", "D", "esa.1", "g0")),
                is_equivalent_to(c(coef(example.data$fits$bearing.hn, "all")[c(3, 1, 4)], 1)))
})

test_that("testing calculation of probability detection surface", {
    esa.test <- sum(ascr:::p.dot(example.data$fits$simple.hn))*attr(example.data$mask, "area")
    esa <- get.par(example.data$fits$simple.hn, "esa")
    relative.error <- (esa.test - esa)/esa
    expect_true(relative.error < 1e-4)
})
