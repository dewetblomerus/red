# Configuration for Credo

%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
