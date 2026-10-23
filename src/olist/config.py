import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    project_id: str = os.getenv("OLIST_PROJECT_ID")
    region: str = os.getenv("OLIST_REGION")
    bq_location: str = os.getenv("OLIST_BQ_LOCATION")

    @property
    def landing_bucket(self) -> str:
        return f"{self.project_id}-landing"

    def table(self, layer: str, name: str) -> str:
        return f"{self.project_id}.${layer}.name"


settings = Settings()
