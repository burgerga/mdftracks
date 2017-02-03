library(mdftracks)
context("Writing mdf tracks")

# Load reference data
load('test_df.RData')

test_that("Data frames with columns id, t, x, y, z (MotilyLab) can be exported
          using default arguments (numeric columns)", {
  expected_output <- "^MTrackJ [0-9.]+ Data File
Assembly 1
Cluster 1
Track 1
Point 1 187.1 263.2 27.4 1.0 1.0
Point 2 309.2 264.4 15.8 2.0 1.0
Track 2
Point 1 18.4 438.5 28.1 1.0 1.0
Point 2 142.9 58.6 28.2 2.0 1.0
Point 3 290.1 197.5 18.8 3.0 1.0
Track 3
Point 1 310.1 15.4 5.8 1.0 1.0
Track 4
Point 1 99.1 33.5 22.5 1.0 1.0
Point 2 220.2 396.0 16.4 2.0 1.0
Track 5
Point 1 8.4 305.8 30.2 1.0 1.0
Point 2 84.7 227.7 21.1 2.0 1.0
End of MTrackJ Data File$"
  expect_output(write.mdf(test.df[,c('uid','t', 'x', 'y', 'z')]),
                expected_output)
})

test_that("time is correctly scaled", {
  expected_output <- "^MTrackJ [0-9.]+ Data File
Assembly 1
Cluster 1
Track 1
Point 1 187.1 263.2 27.4 0.1 1.0
Point 2 309.2 264.4 15.8 0.2 1.0
Track 2
Point 1 18.4 438.5 28.1 0.1 1.0
Point 2 142.9 58.6 28.2 0.2 1.0
Point 3 290.1 197.5 18.8 0.3 1.0
Track 3
Point 1 310.1 15.4 5.8 0.1 1.0
Track 4
Point 1 99.1 33.5 22.5 0.1 1.0
Point 2 220.2 396.0 16.4 0.2 1.0
Track 5
Point 1 8.4 305.8 30.2 0.1 1.0
Point 2 84.7 227.7 21.1 0.2 1.0
End of MTrackJ Data File$"
            expect_output(write.mdf(test.df[,c('uid','t', 'x', 'y', 'z')],
                                    scale.time = 0.1),
                          expected_output)
})

test_that("Default channel is set correctly", {
  expected_output <- "^MTrackJ [0-9.]+ Data File
Assembly 1
Cluster 1
Track 1
Point 1 187.1 263.2 27.4 1.0 2.0
Point 2 309.2 264.4 15.8 2.0 2.0
Track 2
Point 1 18.4 438.5 28.1 1.0 2.0
Point 2 142.9 58.6 28.2 2.0 2.0
Point 3 290.1 197.5 18.8 3.0 2.0
Track 3
Point 1 310.1 15.4 5.8 1.0 2.0
Track 4
Point 1 99.1 33.5 22.5 1.0 2.0
Point 2 220.2 396.0 16.4 2.0 2.0
Track 5
Point 1 8.4 305.8 30.2 1.0 2.0
Point 2 84.7 227.7 21.1 2.0 2.0
End of MTrackJ Data File$"
  expect_output(write.mdf(test.df[,c('uid','t', 'x', 'y', 'z')],
                          default.channel = 2),
                expected_output)
})

test_that("2D data has Z = 1.0", {
  expected_output <- "^MTrackJ [0-9.]+ Data File
Assembly 1
Cluster 1
Track 1
Point 1 187.1 263.2 1.0 1.0 1.0
Point 2 309.2 264.4 1.0 2.0 1.0
Track 2
Point 1 18.4 438.5 1.0 1.0 1.0
Point 2 142.9 58.6 1.0 2.0 1.0
Point 3 290.1 197.5 1.0 3.0 1.0
Track 3
Point 1 310.1 15.4 1.0 1.0 1.0
Track 4
Point 1 99.1 33.5 1.0 1.0 1.0
Point 2 220.2 396.0 1.0 2.0 1.0
Track 5
Point 1 8.4 305.8 1.0 1.0 1.0
Point 2 84.7 227.7 1.0 2.0 1.0
End of MTrackJ Data File$"
  expect_output(write.mdf(test.df[,c('uid','t', 'x', 'y')],
                          pos.columns = letters[24:25]),
                expected_output)
})

test_that("all columns specified", {
  expected_output <- "^MTrackJ [0-9.]+ Data File
Assembly 1
Cluster 1
Track 1
Point 1 187.1 263.2 27.4 1.0 2.0
Point 3 309.2 264.4 15.8 2.0 2.0
Track 2
Point 1 18.4 438.5 28.1 1.0 2.0
Point 2 142.9 58.6 28.2 2.0 2.0
Point 5 290.1 197.5 18.8 3.0 2.0
Cluster 2
Track 1
Point 1 310.1 15.4 5.8 1.0 2.0
Track 2
Point 1 99.1 33.5 22.5 1.0 2.0
Point 2 220.2 396.0 16.4 2.0 2.0
Track 3
Point 1 8.4 305.8 30.2 1.0 2.0
Point 2 84.7 227.7 21.1 2.0 2.0
End of MTrackJ Data File$"
  expect_output(write.mdf(test.df, cluster.column = 'cl', id.column = 'id',
                          pos.columns = letters[24:26], channel.column = 'ch',
                          point.column = 'p', time.column = 't'),
                expected_output)
})
