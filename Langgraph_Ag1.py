# %%
from typing import TypedDict
from langgraph.graph import StateGraph

# %%
class AgentState(TypedDict): # Define your class, in laymans term it's the structure of your variable
    message: str
    name: str

def greeting(state: AgentState) -> AgentState: # here you define your function, this task will be executed on the node - "greeter"

    state["message"] = "Hello, how can I assist you today?" + state["message"] #added the variable and input to the state which keeps track of variables and data

    return state

def compliment(state: AgentState) -> AgentState: # another function to be executed on the node - "compliment"
    state["name"] = state["name"] + " You are doing a great job!"
    return state

# %%
graph = StateGraph(AgentState)  # StateGraph creates the graph where we passed our state schema(class)
graph.add_node("greeter", greeting)
graph.set_entry_point("greeter") #Node needs a starting point
graph.add_node("complimenter", compliment) # we added a node to the graph which is responsible to execute the compliment function/ our task
graph.set_finish_point("complimenter") #Node needs a finishing point
graph.add_edge("greeter", "complimenter") # we added an edge to the graph which connects the two nodes
app = graph.compile() 

# %%
from IPython.display import display, Image
display(Image(app.get_graph().draw_mermaid_png()))

# %%
result = app.invoke({"message": "I have entered this message"}) # Run the app with an initial state
result

# %%
compliment = app.invoke({"name": "Shubham", "message": "I have entered this message"}) # Run the app with an initial state
compliment


