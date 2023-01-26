# Developer Notes

## Linter
There are currently three types of rules:

 - **Field-level rules**: these are rules that apply to an individual `dimension`, `dimension_group`, or `measure`. An example is the `DescriptionRule` that specifies that these field should contain a description.
 - **File-level rules**: these are rules that apply to the file as a whole, such as there should only be one view per file (`OneViewPerFileRule`) or that files should specify a data source with `sql_table_name` or `derived_table` (`DataSourceRule`).
 - **Other rules**: the third category are other rules. The only, current example is the `NoOrphansRule` that says that each view should be referenced by at least one explore. While it sounds like a file-level rule, the code can only assess whether the rule is passed once it has parsed *all* of the files, and not from a single file. Thus, it has to be handled differently than the file-level rules.

### Rule Interfaces

Field-level rules have an interface:
 
```
    def run(self, lookml_field):
        '''run the rule

        Args:
            lookml (LookMLField): LookMLField instance

        Returns:
            (tuple): tuple containing:

                relevant (bool): is this rule relevant for this JSON chunk?

                passed (bool): did the rule pass?

        '''
```
which is in `src.linter.field_rule` file where `LookMLField` is a wrapper around the JSON data for that field. 
 
These rules must always return two Boolean flags:
 
 - **Relevant**: was the rule relevant for this fragment. So, if a rule that only applies to `measures` is fed JSON from a `dimension_group`, it should return `False`.
 - **Passed**: did the rule pass. If it was not relevant, it should return `None`. 
 
File-level rules have a similar interface:

```
    def run(self, lookml):
        '''run the rule

        Args:
            lookml (LookML): LookML instance

        Returns:
            (tuple): tuple containing:

                relevant (bool): is this rule relevant for this JSON chunk?

                passed (bool): did the rule pass?

        '''
```
which is in the `src.linter.rule` file.
This time however, the input is an instance of `LookML` which is a wrapper around the parsed JSON of the whole LookML file.

Both `LookML` and `LookMLField` provide methods for querying the LookML attributes without having to intimately understand the JSON representation.
For instance, for the `DrillDownRule`, which only applies to measures, the implementation is:

```
    def run(self, lookml_field):
        if not lookml_field.is_measure():
            return False, None

        if not lookml_field.has_key('drill_fields') or lookml_field.drill_fields == []:
            return True, False
        return True, True
```
which should be relatively easy to understand. 

For any functionality not covered by the methods in `LookML` or `LookMLField`, you can always access and examine the underlying JSON representation via `lookml.json_data` and `lookml_field.json_data`.
You should examine the parsed JSON of some LookML files to see the structure. For instance,  dimension's JSON for a dimension `city_code` is relatively intuitive:

```
{
      "type": "string",
      "description": "this is a description",
      "sql": "${TABLE}.CityCode ",
      "_dimension": "city_code",
      "_type": "dimension",
      "_n": 0,
      "_view": "dim_geography"
}
```

If you implement a new rule, it will need to be registered with the `RuleFactory` before it can be used. 
You can register new rules using the `RuleFactory` singleton:

```
from src.linter.rule_factory import RuleFactory

from mymodules.myawesomerule import MyAwesomeRule

RuleFactory().register('MyAwesomeRule', MyAwesomeRule)

```

### Parameterization of Rules
It is possible to pass parameters, other than `name` and `run`, into the rules via the configuration file. An example is the lexicon rule which checks that certain phrases are *not* mentioned in the field name or description.

```
"rules": {
        "file_level_rules" : [
            {"name": "DataSourceRule", "run": true},
            {"name": "OneViewPerFileRule", "run": true},
            {"name": "FilenameViewnameMatchRule", "run": true}
        ],
        "field_level_rules": [
            {"name": "DescriptionRule", "run": true},
            {"name": "DrillDownRule", "run": true},
            {"name": "YesNoNameRule", "run": true},
            {"name": "CountNameRule", "run": true},
            {"name": "AllCapsRule", "run": true}
            {"name": "LexiconRule", "run": true, "phrases": ["Subscriber",  "Subscription", "studio"]}
        ]
    },

```
The complete configuration dictionary for the `LexiconRule`, i.e.

```
    {"name": "LexiconRule", "run": true, "phrases": ["Subscriber",  "Subscription", "studio"]}
```
is passed into the `LexiconRule` during instantiation. 

This is true for all rules--this functionality is baked into the base `AbsrtractRule` class---any additional keys in the configuration dictionary are available to the rule.
