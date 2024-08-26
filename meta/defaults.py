from typing import Dict

comp_docs = open(
	"/home/nathan/.local/share/Steam/steamapps/common/Noita/tools_modding/component_documentation.txt",
	"r",
).read()
print(comp_docs)
cur_comp = ""
comps: Dict[str, Dict[str, str]] = {}
for line in comp_docs.split("\n"):
	if line == "" or line[1] == "-":
		continue
	print(line)
	if line[0] != " ":
		cur_comp = line
		comps[cur_comp] = {}
		continue
	if line[27] != " ":
		continue
	name = line[28:].split(" ")[0]
	value = line[92:].split(" ")[0]
	if value[0] not in "0123456789":
		value = '"' + value + '"'
	if value == '"-"':
		value = "nil"
	comps[cur_comp][name] = value

out = "return {\n"
for k, v in comps.items():
	out += k + "= {\n"
	for k2, v2 in v.items():
		out += k2 + "=" + v2 + ",\n"
	out += "\n},"
out += "\n}"
open("defaults.lua", "w").write(out)
