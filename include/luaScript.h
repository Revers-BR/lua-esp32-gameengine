#ifndef LUASCRIPT_H
#define LUASCRIPT_H

const char* lua_scripts[] = {
  R"(
if not ball then
  ball = {
    x = 10,
    y = 10,
    dx = 10,
    dy = 10,
    r = 20
  }
end
local w, h = lge.get_canvas_size()
while true do
  lge.clear_canvas()
  ball.x = ball.x + ball.dx
  ball.y = ball.y + ball.dy
  if (ball.x - ball.r < 0 and ball.dx < 0) or (ball.x + ball.r > w and ball.dx > 0) then
    ball.dx = -ball.dx
  end
  if (ball.y - ball.r < 0 and ball.dy < 0) or (ball.y + ball.r > h and ball.dy > 0) then
    ball.dy = -ball.dy
  end
  lge.draw_circle(ball.x, ball.y, ball.r, "#00B6FF")
  lge.draw_text(50, 50, "Bouncing Ball", "#ffffff")
  lge.present()
  lge.delay(160)
end
)"
  ,
  nullptr
};

const char* script_names[] = {
  "Bouncing Ball",
  nullptr
};

#endif // LUASCRIPT_H
