#' Split long vector to short
#'
#' @param data vector data, extracted from pdf, mostly character.
#' @return splited data, each element has a each record.
#' @examples
#' \dontrun{conbini |> pt_cell()}
pt_cell <- \(data) {
  data |>
    stringr::str_split(" +")
}