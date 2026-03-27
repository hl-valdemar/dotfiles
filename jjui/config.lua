function setup(config)
  local function delta_pager()
    return [=[bash -c '
      if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
        export BAT_THEME="Miasma Dark"
        export DELTA_FEATURES=dark-mode
      else
        export BAT_THEME="Miasma Light"
        export DELTA_FEATURES=light-mode
      fi
      exec delta --paging=always --line-numbers
    ']=]
  end

  config.action("revisions.diff", function()
    local id = context.change_id()
    if id then
      exec_shell("jj diff -r " .. id .. " --git | " .. delta_pager())
    end
  end, { desc = "show diff with delta" })

  config.action("revisions.details.diff", function()
    local id = context.change_id()
    local file = context.file()
    if id and file then
      exec_shell("jj diff -r " .. id .. " " .. file .. " --git | " .. delta_pager())
    end
  end, { desc = "show file diff with delta" })
end
