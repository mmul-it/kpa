all
# With so many code blocks and tables we can't have lines just 80 chars long
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md#md013---line-length
exclude_rule 'MD013'
# There is no way to make this work, somehow
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md#md007---unordered-list-indentation
exclude_rule 'MD007'
# We want ordered list with style 'ordered'
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md#md029---ordered-list-item-prefix
rule 'MD029', :style => :ordered
# Marp wants html in some ways, so this rule should be omitted
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md#md007---unordered-list-indentation
exclude_rule 'MD033'
# We want to check for duplicated headers only inside siblings, but this
# doesen't work in any way:
# rule 'MD024', :siblings_only => true
# So we must exclude the rule as whole.
# https://github.com/DavidAnson/vscode-markdownlint/issues/238
exclude_rule 'MD024'
