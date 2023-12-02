# Configuration for Credo

%{
  configs: [
    %{
      name: "default",
      strict: false,
      checks: [
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
