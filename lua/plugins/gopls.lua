return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = false,
              },
            },
          },
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          env = {
            GOPACKAGESDRIVER = vim.fn.getcwd() .. "/tools/gopackagesdriver.sh",
          },
          settings = {
            gopls = {
              workspaceFiles = {
                "**/BUILD",
                "**/WORKSPACE",
                "**/*.{bzl,bazel}",
              },
              directoryFilters = {
                "-bazel-bin",
                "-bazel-out",
                "-bazel-testlogs",
              },
            },
          },
        },
      },
    },
  },
}
