"""Give a tf2onnx model stable names, so the same conversion always writes the same bytes.

tf2onnx numbers generated constants and nodes from counters whose order changes between
runs. Rename every node, initializer and intermediate tensor by its first use in node order
(inputs and outputs keep their names) and sort the initializers the same way.
"""
import sys
import onnx

model = onnx.load(sys.argv[1])
graph = model.graph
keep = {i.name for i in graph.input} | {o.name for o in graph.output}
names = {}

def stable(name):
    if not name or name in keep:
        return name
    if name not in names:
        names[name] = f"t{len(names)}"
    return names[name]

for i, node in enumerate(graph.node):
    node.name = f"n{i}"
    node.input[:] = [stable(n) for n in node.input]
    node.output[:] = [stable(n) for n in node.output]
for init in graph.initializer:
    init.name = stable(init.name)
for info in graph.value_info:
    info.name = stable(info.name)
order = {name: k for k, name in enumerate(names.values())}
inits = sorted(graph.initializer, key=lambda t: order.get(t.name, len(order)))
del graph.initializer[:]
graph.initializer.extend(inits)
infos = sorted(graph.value_info, key=lambda t: order.get(t.name, len(order)))
del graph.value_info[:]
graph.value_info.extend(infos)
onnx.checker.check_model(model)
onnx.save(model, sys.argv[2])
