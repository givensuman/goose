return {
  "folke/sidekick.nvim",
  ---@type sidekick.Config
  opts = {
    cli = {
      win = {
        layout = "right",
        split = {
          width = 50,
        },
      },

    },
  },
  keys = {
    {
      "<leader>aa",
      function() require("sidekick.cli").toggle({ name = "opencode" }) end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function() require("sidekick.cli").select() end,
      desc = "Select CLI",
    },
    {
      "<leader>ad",
      function() require("sidekick.cli").close({ name = "opencode" }) end,
      desc = "Detach a CLI Session",
    },
    {
      "<leader>at",
      function() require("sidekick.cli").send({
        name = "opencode",
        msg = "{this}",
      }) end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>af",
      function() require("sidekick.cli").send({
        name = "opencode",
        msg = "{file}",
      }) end,
      desc = "Send File",
    },
    {
      "<leader>av",
      function() require("sidekick.cli").send({
        name = "opencode",
        msg = "{selection}",
      }) end,
      mode = { "x" },
      desc = "Send Visual Selection",
    },
    {
      "<leader>ap",
      function() require("sidekick.cli").prompt({ name = "opencode" }) end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
  },
}
