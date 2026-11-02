///|
pub fn handle(request : Request) -> Result[Response, Error_] {
  let request_id = header_value(request.headers, "x-request-id")
  match request.method_ {
    "GET" => list_items(request, request_id)
    "POST" => create_item(request, request_id)
    "PUT" => update_item(request, request_id)
    "DELETE" => delete_item(request, request_id)
    _ => Err({ code: BAD_REQUEST, message: "method " + request.method_ + " is not supported" })
  }
}

///|
fn list_items(request : Request, request_id : String?) -> Result[Response, Error_] {
  let mut items = ["notebook", "pencil"]
  match query_param(request.query, "name") {
    Some(name) =>
      if name != "notebook" && name != "pencil" {
        return Err({ code: NOT_FOUND, message: "item " + name + " was not found" })
      } else {
        items = [name]
      }
    None => ()
  }
  let mut rendered = ""
  for i = 0; i < items.length(); i = i + 1 {
    if i > 0 {
      rendered = rendered + ","
    }
    rendered = rendered + "{\"name\":" + json_string(items[i]) + "}"
  }
  Ok(respond(200, request_id, meta(request, request_id) + ",\"items\":[" + rendered + "]}"))
}

///|
fn create_item(request : Request, request_id : String?) -> Result[Response, Error_] {
  match json_string_field(request.body, "name") {
    None => Err({ code: BAD_REQUEST, message: "body must be a JSON object with a string name" })
    Some(name) =>
      Ok(respond(201, request_id, meta(request, request_id) + ",\"created\":{\"name\":" + json_string(name) + "}}"))
  }
}

///|
fn update_item(request : Request, request_id : String?) -> Result[Response, Error_] {
  match query_param(request.query, "id") {
    None => Err({ code: BAD_REQUEST, message: "query parameter id is required" })
    Some(id) => {
      let body = request.body.trim().to_string()
      if body.has_prefix("{") {
        Ok(respond(200, request_id, meta(request, request_id) + ",\"updated\":{\"id\":" + json_string(id) + ",\"body\":" + json_string(body) + "}}"))
      } else {
        Err({ code: BAD_REQUEST, message: "body must be a JSON object" })
      }
    }
  }
}

///|
fn delete_item(request : Request, request_id : String?) -> Result[Response, Error_] {
  match query_param(request.query, "id") {
    None => Err({ code: BAD_REQUEST, message: "query parameter id is required" })
    Some(id) =>
      Ok(respond(200, request_id, meta(request, request_id) + ",\"deleted\":" + json_string(id) + "}"))
  }
}

///|
fn meta(request : Request, request_id : String?) -> String {
  "{\"function\":" + json_string("{{project-name}}") + ",\"language\":\"moonbit\",\"method\":" + json_string(request.method_) + ",\"path\":" + json_string(request.path) + ",\"query\":" + json_optional(request.query) + ",\"requestId\":" + json_optional(request_id)
}

///|
fn respond(status : UInt, request_id : String?, body : String) -> Response {
  let headers : Array[Header] = []
  headers.push({ name: "content-type", value: "application/json" })
  match request_id {
    Some(id) => headers.push({ name: "x-request-id", value: id })
    None => ()
  }
  { status, headers, body }
}

///|
fn header_value(headers : Array[Header], name : String) -> String? {
  for i = 0; i < headers.length(); i = i + 1 {
    if headers[i].name.equal_ignore_ascii_case(name) {
      return Some(headers[i].value)
    }
  }
  None
}

///|
fn query_param(query : String?, key : String) -> String? {
  match query {
    None => None
    Some(text) => {
      let needle = key + "="
      for part in text.split("&") {
        let piece = part.to_string()
        if piece.has_prefix(needle) {
          return Some(piece.substring(start=needle.length(), end=piece.length()))
        }
      }
      None
    }
  }
}

///|
fn json_string_field(body : String, field : String) -> String? {
  let needle = "\"" + field + "\""
  match find_at(body, needle, 0) {
    None => None
    Some(at) => {
      let mut rest = body.substring(start=at + needle.length(), end=body.length()).trim().to_string()
      if !rest.has_prefix(":") {
        return None
      }
      rest = rest.substring(start=1, end=rest.length()).trim().to_string()
      if !rest.has_prefix("\"") {
        return None
      }
      rest = rest.substring(start=1, end=rest.length())
      match find_at(rest, "\"", 0) {
        None => None
        Some(stop) => Some(rest.substring(start=0, end=stop))
      }
    }
  }
}

///|
fn find_at(text : String, needle : String, start : Int) -> Int? {
  let mut index = start
  while index + needle.length() <= text.length() {
    if text.substring(start=index, end=index + needle.length()) == needle {
      return Some(index)
    }
    index = index + 1
  }
  None
}

///|
fn json_string(value : String) -> String {
  "\"" +
  value.replace_all(old="\\", new="\\\\").replace_all(old="\"", new="\\\"").replace_all(
    old="\n",
    new="\\n",
  ) +
  "\""
}

///|
fn json_optional(value : String?) -> String {
  match value {
    None => "null"
    Some(text) => json_string(text)
  }
}
