return {
  {
    "smoka7/hop.nvim",
    version = "*",
    opts = {
      keys = "etovxqpdygfblzhckisuran",
      dim_unmatches = true,
      teasing = true,
    },
    keys = {
      {
        "s",
        function()
          local hint = require("hop.hint")
          require("hop").hint_char1({
            direction = hint.HintDirection.AFTER_CURSOR,
            current_line_only = false,
          })
        end,
        mode = { "n", "x" },
        desc = "Hop forward",
      },
      {
        "S",
        function()
          local hint = require("hop.hint")
          require("hop").hint_char1({
            direction = hint.HintDirection.BEFORE_CURSOR,
            current_line_only = false,
          })
        end,
        mode = { "n", "x" },
        desc = "Hop backward",
      },
    },
  },
}
