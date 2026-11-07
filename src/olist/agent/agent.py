from langchain.chat_models import init_chat_model
from langchain.agents import create_agent
from olist.agent.tools import run_gql
from olist.agent.prompts import system_prompt

MODEL = "gemini-3.8-flash"  # use the current Gemini model (https://aistudio.google.com/docs/models)


def build_agent():
    llm = init_chat_model(
        model=MODEL,
        model_provider="google_vertexai",
        temperature=0,
        location="global",
        project="olist-medallion",
    )
    return create_agent(llm, tools=[run_gql], system_prompt=system_prompt())


def ask(agent, question: str) -> str:
    result = agent.invoke(
        {"messages": [{"role": "user", "content": question}]},
        config={"recursion_limit": 12},
    )

    for msg in result["messages"]:
        for call in getattr(msg, "tool_calls", None) or []:
            print(f"--- {call['name']} ---\n{call['args']}\n")
    return result["messages"][-1].content
