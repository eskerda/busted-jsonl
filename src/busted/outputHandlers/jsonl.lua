local json = require 'dkjson'

return function(options)
  local busted = require 'busted'
  local handler = require 'busted.outputHandlers.base'()

  handler.testEnd = function(element, parent, status, debug)
    print(json.encode(handler.format(element, parent, status, debug)))
    return nil, true
  end

  busted.subscribe({ 'test', 'end' }, handler.testEnd, { predicate = handler.cancelOnPending })
  return handler
end
