import nonebot
from nonebot.adapters.onebot.v11 import Adapter


def main() -> None:
    nonebot.init()
    nonebot.get_driver().register_adapter(Adapter)
    nonebot.load_from_toml("pyproject.toml")
    nonebot.run()


if __name__ == "__main__":
    main()
