
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pdftabler

<!-- badges: start -->

<!-- badges: end -->

The goal of pdftabler is to create arranged data frame extracted from
PDF file by R. It deals especially with time-series data. This package
is required pdftools.

## Installation

You can install the development version of pdftabler from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MTRBEKTCBT/pdftabler")
```

## Example

``` r
library(pdftabler)
```

The data extracted from a package `pdftools::pdf_text` is often dirty by
unnecessary spaces and is a vector rather than a dataframe. This is a
basic example which shows you how to get the data obtained from pdf to a
complete dataframe.

Suppose we already have vector data extracted by `pdftools::pdf_text`
that has just been extracted. For illustration, we’ll use `conbini` data
which records [JFA sales from 2005
to 2021](https://www.jfa-fc.or.jp/particle/320.html) to show how each
function works.

First of all, the data has to be split into each cell of table which
originally displayed in PDF. To process this task, use `pt_cell()` and
`pt_split()`.

``` r
conbini |>
  pt_cell() |>
  pt_split(initial = 29, n_col = 15, n_row = 2)
#> [[1]]
#>  [1] "1月"     "561,491" "1.6%"    "513,357"
#>  [5] "-1.7%"   "38,861"  "2.1%"    "908,165"
#>  [9] "2.4%"    "838,523" "-0.6%"   "618.3"  
#> [13] "-0.8%"   "612.2"   "-1.1%\n"
#> 
#> [[2]]
#>  [1] "2月"     "523,385" "-1.4%"   "477,521"
#>  [5] "-2.5%"   "39,257"  "2.2%"    "861,472"
#>  [9] "-1.5%"   "791,004" "-3.7%"   "607.5"  
#> [13] "0.1%"    "603.7"   "1.2%\n"
```

The argument `initial` in `pt_split()` denotes a initial cell for
records. Note that it indicates a record for inner data, do not specify
a raw of column names.

We will also wonder which number is to be `initial`? We can use
`pt_index` to resolve this task. It creates index dataframe that
indicates which place any word or symbol is in the vector.

``` r
key <- sprintf("%d月", 1:12)

idx <-
  conbini |>
  pt_cell() |>
  pt_index(keywords = key)

idx |> head()
#>      V1  V2  V3  V4  V5   V6   V7   V8   V9  V10
#> 1月  29 225 420 615 810 1005 1200 1396 1592 1788
#> 2月  44 240 435 630 825 1020 1215 1411 1607 1803
#> 3月  59 255 450 645 840 1035 1230 1426 1622 1818
#> 4月  74 270 465 660 855 1050 1245 1441 1637 1833
#> 5月  89 285 480 675 870 1065 1260 1456 1652 1848
#> 6月 104 300 495 690 885 1080 1275 1471 1667 1863
#>      V11  V12  V13  V14  V15  V16  V17
#> 1月 1984 2180 2408 2605 2802 2999 3196
#> 2月 1999 2195 2423 2620 2817 3014 3211
#> 3月 2014 2210 2438 2635 2832 3029 3226
#> 4月 2029 2225 2453 2650 2847 3044 3241
#> 5月 2044 2240 2468 2665 2863 3060 3257
#> 6月 2059 2255 2484 2680 2879 3076 3273
```

Now we can use another function `pt_split_multi` that can handle
dataframe as argument. It is a recursive version of function `pt_split`.

``` r
df <-
conbini |>
  pt_cell() |>
  pt_split_multi(index = idx)

df |> head()
#> # A tibble: 6 x 15
#>   V1    V2      V3    V4     V5    V6    V7    V8   
#>   <chr> <chr>   <chr> <chr>  <chr> <chr> <chr> <chr>
#> 1 1月   561,491 1.6%  513,3~ -1.7% 38,8~ 2.1%  908,~
#> 2 2月   523,385 -1.4% 477,5~ -2.5% 39,2~ 2.2%  861,~
#> 3 3月   601,531 2.2%  549,1~ -1.4% 39,1~ 2.3%  985,~
#> 4 4月   592,949 2.4%  541,2~ -0.9% 39,1~ 2.4%  994,~
#> 5 5月   600,660 1.7%  548,3~ -1.9% 39,2~ 2.5%  1,01~
#> 6 6月   601,371 2.5%  548,7~ -1.3% 39,3~ 2.8%  1,03~
#> # ... with 7 more variables: V9 <chr>, V10 <chr>,
#> #   V11 <chr>, V12 <chr>, V13 <chr>, V14 <chr>,
#> #   V15 <chr>
```

Then, we may also complain about data type, that all of columns in data
are character but we can easily modify this to use some methods already
exist. Since the example data is essentially numerical and limited in
time period, I packed a method for it that processes required task at
one step.

``` r
df |> pt_modify(2005) |> head()
#> # A tibble: 6 x 16
#>    year month     V2    V3     V4    V5    V6    V7
#>   <int> <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
#> 1  2005     1 561491   1.6 513357  -1.7 38861   2.1
#> 2  2005     2 523385  -1.4 477521  -2.5 39257   2.2
#> 3  2005     3 601531   2.2 549144  -1.4 39118   2.3
#> 4  2005     4 592949   2.4 541234  -0.9 39170   2.4
#> 5  2005     5 600660   1.7 548391  -1.9 39229   2.5
#> 6  2005     6 601371   2.5 548714  -1.3 39357   2.8
#> # ... with 8 more variables: V8 <dbl>, V9 <dbl>,
#> #   V10 <dbl>, V11 <dbl>, V12 <dbl>, V13 <dbl>,
#> #   V14 <dbl>, V15 <dbl>
```

Now we can analyze the data as always.

``` r
library(ggplot2)
df |>
  pt_modify(2005) |>
  dplyr::mutate(date = stringr::str_c(year, month, "01") |> lubridate::ymd()) |>
  ggplot(aes(date, V5)) +
  geom_line() +
  labs(
    title = "コンビニエンスストアの売上高前年比の推移",
    x = "月",
    y = "既存店売上高前年比"
  )
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
