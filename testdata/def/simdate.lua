local t = t or require "t"
return {
  yes=true,
  no=false,
  empty='',
  chars='[a-zA-Z]+',
  digits='%d+',
  zero=0,
  one=1,
  pi=3.14,
  ts=t.date,
  [true]=[[yes no one pi]],
}