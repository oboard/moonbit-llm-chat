///|
fn main {
  let rl = @readline.new()
  println("Welcome to the chat! (exit/quit to exit)")
  fn next() {
    rl.question("> ", msg => {
      if msg == "exit" || msg == "quit" {
        println("Goodbye!")
        return
      }
      println("Assistant: ")
      @mio.run(() => {
        let _resp = try? @mio.post_stream(
            "http://oboard.fun:2934/v1/chat/completions",
            data={
              "model": "doubao",
              "messages": [{ "role": "user", "content": msg }],
              "stream": true,
            },
            headers={
              "Content-Type": "application/json",
              "Authorization": "Bearer sk-1234567890abcdef1234567890abcdef",
            },
            fn(data) {
              // 处理流式响应数据
              if data.contains("data: ") {
                let json_str = data.replace(old="data: ", new="")
                if json_str.trim_space() != "[DONE]" {
                  // 解析JSON并提取content
                  if json_str.contains("\"content\":") {
                    // 简单提取content内容（这里应该用JSON解析器，但先用字符串处理）
                    let parts = json_str.split("\"content\":\"").collect()
                    if parts.length() > 1 {
                      let content_part = parts[1]
                      let content_end = content_part.split("\"").collect()
                      if content_end.length() > 0 {
                        let content = content_end[0]
                        if content != "" {
                          println(content)
                        }
                      }
                    }
                  }
                  // 检查是否完成
                  if json_str.contains("\"finish_reason\":\"stop\"") {
                    next() // 只有在stop时才调用next
                  }
                }
              }
            },
          )
        println("")
      })
    })
  }

  next()
}
