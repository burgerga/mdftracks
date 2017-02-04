library(mdftracks)
context("Reading mdf tracks")

# Load reference data
load('test_df.RData')


test_that("Loading without arguments should have cl, id, t, x:z", {
  expect_equivalent(read.mdf('test_mdf.mdf'),
                    test.df[,c('cl', 'id', 't', letters[24:26])])
})

test_that("Testing drop.Z for 2D data", {
  expect_equivalent(read.mdf('test_mdf.mdf', drop.Z = T),
                    test.df[,c('cl', 'id', 't', letters[24:25])])
})

test_that("Include point numbers", {
  expect_equivalent(read.mdf('test_mdf.mdf', include.point.numbers = T),
                    test.df[,c('cl', 'id', 't', letters[24:26], 'p')])
})

test_that("Include channel", {
  expect_equivalent(read.mdf('test_mdf.mdf', include.channel = T),
                    test.df[,c('cl', 'id', 't', letters[24:26], 'ch')])
})

test_that("Generate unique ids", {
  expect_equivalent(read.mdf('test_mdf.mdf', generate.unique.ids = T),
                    test.df[,c('cl', 'id', 't', letters[24:26], 'uid')])
})

test_that("Error if not mdf format", {
  expect_error(read.mdf(text = "not mdf"),
               "does not appear to be an MTrackJ Data File")
})
