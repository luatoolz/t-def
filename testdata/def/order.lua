local t = t or require "t"

return {
  done=t.boolean,
  ok=t.boolean,
  message=t.string,
  created=t.integer,
  finished=t.integer,
  job=t.def.job,
}