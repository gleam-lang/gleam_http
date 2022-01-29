import gleam/option.{None, Some}
import gleam/uri.{Uri}
import gleam/string
import gleam/http.{Https}
import gleam/http/request.{Request}
import gleeunit/should

pub fn req_to_uri_test() {
  let make_request = fn(scheme) -> Request(Nil) {
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: scheme,
      host: "sky.net",
      port: None,
      path: "/sarah/connor",
      query: None,
    )
  }

  http.Https
  |> make_request
  |> request.to_uri
  |> should.equal(Uri(
    Some("https"),
    None,
    Some("sky.net"),
    None,
    "/sarah/connor",
    None,
    None,
  ))

  http.Http
  |> make_request
  |> request.to_uri
  |> should.equal(Uri(
    Some("http"),
    None,
    Some("sky.net"),
    None,
    "/sarah/connor",
    None,
    None,
  ))
}

pub fn req_from_uri_test() {
  let uri =
    Uri(Some("https"), None, Some("sky.net"), None, "/sarah/connor", None, None)
  uri
  |> request.from_uri
  |> should.equal(Ok(Request(
    method: http.Get,
    headers: [],
    body: "",
    scheme: http.Https,
    host: "sky.net",
    port: None,
    path: "/sarah/connor",
    query: None,
  )))
}

pub fn path_segments_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "nostromo.ship",
      port: None,
      path: "/ellen/ripley",
      query: None,
    )

  should.equal(["ellen", "ripley"], request.path_segments(request))
}

pub fn get_query_test() {
  let make_request = fn(query) {
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: query,
    )
  }

  let request = make_request(Some("foo=x%20y"))
  should.equal(Ok([#("foo", "x y")]), request.get_query(request))

  let request = make_request(None)
  should.equal(Ok([]), request.get_query(request))

  let request = make_request(Some("foo=%!2"))
  should.equal(Error(Nil), request.get_query(request))
}

pub fn set_query_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )

  let query = [#("answer", "42"), #("test", "123")]
  let updated_request = request.set_query(request, query)
  updated_request.query
  |> should.equal(Some("answer=42&test=123"))

  let empty_query = []
  let updated_request = request.set_query(request, empty_query)
  updated_request.query
  |> should.equal(Some(""))
}

pub fn get_req_header_test() {
  let make_request = fn(headers) {
    Request(
      method: http.Get,
      headers: headers,
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )
  }

  let header_key = "GLEAM"
  let request = make_request([#("answer", "42"), #("gleam", "awesome")])
  request
  |> request.get_header(header_key)
  |> should.equal(Ok("awesome"))

  let request = make_request([#("answer", "42")])
  request
  |> request.get_header(header_key)
  |> should.equal(Error(Nil))
}

pub fn set_req_body_test() {
  let body =
    "<html>
      <body>
        <title>Gleam is the best!</title>
      </body>
    </html>"

  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )

  let updated_request =
    request
    |> request.set_body(body)

  updated_request.body
  |> should.equal(body)
}

pub fn set_method_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: "",
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )

  let updated_request_method = http.Post
  let updated_request =
    request
    |> request.set_method(updated_request_method)

  updated_request.method
  |> should.equal(http.Post)
}

pub fn map_req_body_test() {
  let request =
    request.new()
    |> request.set_body("abcd")

  let expected_updated_body = "dcba"
  let updated_request = request.map(request, string.reverse)

  updated_request.body
  |> should.equal(expected_updated_body)
}

pub fn set_scheme_test() {
  let original_request = request.new()

  original_request.scheme
  |> should.equal(Https)

  let updated_request =
    original_request
    |> request.set_scheme(http.Http)

  // scheme should be updated
  updated_request.scheme
  |> should.equal(http.Http)
}

pub fn set_host_test() {
  let new_host = "github"
  let original_request = request.new()
  original_request.host
  |> should.equal("localhost")

  let updated_request =
    original_request
    |> request.set_host(new_host)

  // host should be updated
  updated_request.host
  |> should.equal(new_host)
}

pub fn set_port_test() {
  let original_request = request.new()

  original_request.port
  |> should.equal(None)

  let updated_request =
    original_request
    |> request.set_port(4000)

  // port should be updated
  updated_request.port
  |> should.equal(Some(4000))
}

pub fn set_path_test() {
  let new_path = "/gleam-lang"
  let original_request = request.new()
  original_request.path
  |> should.equal("")

  let updated_request =
    original_request
    |> request.set_path(new_path)

  // path should be updated
  updated_request.path
  |> should.equal("/gleam-lang")
}

pub fn prepend_req_header_test() {
  let headers = []
  let request =
    Request(
      method: http.Get,
      headers: headers,
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )
    |> request.prepend_header("answer", "42")

  request.headers
  |> should.equal([#("answer", "42")])

  let request =
    request
    |> request.prepend_header("gleam", "awesome")

  // request should have two headers now
  request.headers
  |> should.equal([#("gleam", "awesome"), #("answer", "42")])
}

pub fn get_req_cookies_test() {
  request.new()
  |> request.prepend_header("cookie", "k1=v1; k2=v2")
  |> request.get_cookies()
  |> should.equal([#("k1", "v1"), #("k2", "v2")])

  // Standard Header list syntax
  request.new()
  |> request.prepend_header("cookie", "k1=v1, k2=v2")
  |> request.get_cookies()
  |> should.equal([#("k1", "v1"), #("k2", "v2")])

  // Spread over multiple headers
  request.new()
  |> request.prepend_header("cookie", "k2=v2")
  |> request.prepend_header("cookie", "k1=v1")
  |> request.get_cookies()
  |> should.equal([#("k1", "v1"), #("k2", "v2")])

  request.new()
  |> request.prepend_header("cookie", " k1  =  v1 ; k2=v2 ")
  |> request.get_cookies()
  |> should.equal([#("k1", "v1"), #("k2", "v2")])

  request.new()
  |> request.prepend_header("cookie", "k1; =; =123")
  |> request.get_cookies()
  |> should.equal([])

  request.new()
  |> request.prepend_header("cookie", "k\r1=v2; k1=v\r2")
  |> request.get_cookies()
  |> should.equal([])
}

pub fn set_req_cookies_test() {
  let request =
    request.new()
    |> request.set_cookie("k1", "v1")

  request
  |> request.get_header("cookie")
  |> should.equal(Ok("k1=v1"))

  request
  |> request.set_cookie("k2", "v2")
  |> request.get_header("cookie")
  |> should.equal(Ok("k1=v1; k2=v2"))
}
