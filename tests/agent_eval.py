import json
from olist.agent import build_agent, ask

CASES = [
    {"q": "Which state has the most customers?", "must_contain": "SP"},
    {"q": "How many reviews have a score of 1?", "must_contain": "**11,424**"},
    {"q": "Which category earned the most revenue?", "must_contain": "health_beauty"},
    {"q": "How many vendors are registered?", "must_contain": "3,095"},
    {
        "q": "How many delivered orders were placed by customers in São Paulo state (SP)?",
        "must_contain": "40,484",
    },
    {
        "q": "How many orders contained at least one product from the cool_stuff category?",
        "must_contain": "3,658",
    },
    {
        "q": "What is the product name of the item in order ad2b9f8531232554f31be87d5ea9da10?",
        "must_contain": "",
    },
]


def main():
    agent = build_agent()
    passed = 0
    for case in CASES:
        answer = ask(agent, case["q"])[0]["text"]
        ok = case["must_contain"] in answer

        print(
            json.dumps(
                {
                    "question": case["q"],
                    "answer": answer,
                    "must_contain": case["must_contain"],
                    "passed": ok,
                },
                indent=2,
            )
        )

        passed += ok
        print("PASS" if ok else "FAIL", "|", case["q"], "|", answer[:120])
    print(f"\nScore: {passed}/{len(CASES)}")


if __name__ == "__main__":
    main()
