all
# Code blocks and tables are not meant to be just 80 chars long
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md#md013---line-length
rule 'MD013', :ignore_code_blocks => true, :tables => false
# There is no way to make this work, somehow
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md#md007---unordered-list-indentation
exclude_rule 'MD007'
# Marp wants html in some ways, so this rule should be omitted
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md#md007---unordered-list-indentation
exclude_rule 'MD033'
