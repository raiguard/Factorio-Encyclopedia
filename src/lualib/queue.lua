local self = {}

function self.new ()
  return {first = 0, last = -1}
end

function self.pushleft(queue, value)
  local first = queue.first - 1
  queue.first = first
  queue[first] = value
end

function self.pushright(queue, value)
  local last = queue.last + 1
  queue.last = last
  queue[last] = value
end

function self.popleft(queue)
  local first = queue.first
  if first > queue.last then error("queue is empty") end
  local value = queue[first]
  queue[first] = nil        -- to allow garbage collection
  queue.first = first + 1
  return value
end

function self.popright(queue)
  local last = queue.last
  if queue.first > last then error("queue is empty") end
  local value = queue[last]
  queue[last] = nil         -- to allow garbage collection
  queue.last = last - 1
  return value
end

return self