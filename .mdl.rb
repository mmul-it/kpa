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
