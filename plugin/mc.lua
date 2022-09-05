local has_mc, mc = pcall(require, "mc")
if not has_mc then
  return
end

mc.setup()
