local json = require 'dkjson'

return function(options)
  local busted = require 'busted'
  local handler = require 'busted.outputHandlers.base'()
  local cli = require 'cliargs'
  local args = options.arguments

  cli:set_name('jsonl')
  cli:flag('--test',     'output entry per test')
  cli:flag('--file',     'output entry per file')
  cli:flag('--describe', 'output entry per describe')
  cli:option('--depth=DEPTH', 'depth for describe', 0)

  local cli_args = cli:parse(args)

  handler.testEnd = function(element, parent, status, debug)
    local out = handler.format(element, parent, status, debug)
    out.descriptor = "test"
    print(json.encode(out))
    return nil, true
  end

  handler.describeEnd = function(file)
    local function get_source(describe)
      -- Find first availble source
      if describe.it then
        for _, it in ipairs(describe.it) do
          return it.trace.source
        end
      else
        for _, _describe in ipairs(describe.describe) do
          return get_source(_describe)
        end
      end
    end

    local function deepest_describe(describe, name, depth)
      name = name and name .. " " or ""
      if describe.describe and (depth == 0 or depth > 1) then
        for _, _describe in ipairs(describe.describe) do
          deepest_describe(_describe, name .. describe.name, depth > 1 and depth - 1 or 0)
        end
      else
        print(json.encode({
          descriptor = "describe",
          name = name .. describe.name,
          duration = describe.duration,
          starttick = describe.starttick,
          starttime = describe.starttime,
          source = get_source(describe),
        }))
      end
    end

    for _, describe in ipairs(file.describe) do
      deepest_describe(describe, nil, tonumber(cli_args.depth))
    end

    return nil, true
  end

  handler.fileEnd = function(file)
    print(json.encode({
      descriptor = "file",
      name = file.name,
      duration = file.duration,
      starttick = file.starttick,
      starttime = file.starttime,
    }))

    return nil, true
  end

  if cli_args.test or not next(cli_args) then
    busted.subscribe({ 'test', 'end' }, handler.testEnd, { predicate = handler.cancelOnPending })
  end

  if cli_args.file then
    busted.subscribe({ 'file', 'end' }, handler.fileEnd)
  end

  if cli_args.describe then
    busted.subscribe({ 'file', 'end' }, handler.describeEnd)
  end

  return handler
end
