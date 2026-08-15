"""BiliLearn MCP Server — stdio 传输，注册 3 个工具。

协议纪律：stdout 仅供 MCP JSON-RPC 通信，日志一律走 stderr。
"""

from __future__ import annotations

import asyncio
import logging
import sys
from typing import Any

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import TextContent, Tool

from mcp_server import bili as bili_mod
from mcp_server import script as script_mod

logger = logging.getLogger(__name__)

server = Server("bili-learn-mcp")

TOOL_MATERIAL = "bili_video_material"
TOOL_SEARCH = "bili_search_videos"
TOOL_SCRIPT = "bili_video_to_script"


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name=TOOL_MATERIAL,
            description=(
                "提取 Bilibili 视频的文案素材：元数据（标题/UP/时长/数据/简介/分P）+ "
                "字幕全文 + 弹幕精选 + 热门评论，输出结构化 Markdown。"
                "适合写视频文案、做二创、总结视频内容。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "url": {
                        "type": "string",
                        "description": "Bilibili 视频链接，支持 BV 号、av 号、完整 URL",
                    },
                    "include_danmaku": {
                        "type": "boolean",
                        "description": "是否包含弹幕精选，默认 true",
                    },
                    "include_comments": {
                        "type": "boolean",
                        "description": "是否包含热门评论，默认 true",
                    },
                    "include_timestamps": {
                        "type": "boolean",
                        "description": "字幕/弹幕是否保留时间戳，默认 false",
                    },
                    "danmaku_limit": {
                        "type": "integer",
                        "description": "弹幕条数上限，默认 500",
                    },
                    "comment_limit": {
                        "type": "integer",
                        "description": "评论条数上限，默认 30",
                    },
                },
                "required": ["url"],
            },
        ),
        Tool(
            name=TOOL_SEARCH,
            description=(
                "搜索 Bilibili 视频，返回结构化列表（标题/BV/UP/播放量/时长/简介）。"
                "适合找参考视频、找选题素材。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "搜索关键词"},
                    "limit": {
                        "type": "integer",
                        "description": "最多返回条数，默认 8",
                    },
                },
                "required": ["query"],
            },
        ),
        Tool(
            name=TOOL_SCRIPT,
            description=(
                "根据 Bilibili 视频素材，用项目配置的 AI 一键生成视频文案/口播稿。"
                "支持多种风格：口播/解说/种草/盘点/故事/干货。"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "url": {
                        "type": "string",
                        "description": "Bilibili 视频链接",
                    },
                    "style": {
                        "type": "string",
                        "enum": ["口播", "解说", "种草", "盘点", "故事", "干货"],
                        "description": "文案风格，默认口播",
                    },
                    "target_words": {
                        "type": "integer",
                        "description": "目标字数，默认 800",
                    },
                    "extra_hint": {
                        "type": "string",
                        "description": "额外要求（目标受众/平台/语气等），可选",
                    },
                },
                "required": ["url"],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict[str, Any]) -> list[TextContent]:
    try:
        if name == TOOL_MATERIAL:
            markdown = await bili_mod.fetch_material(
                arguments.get("url", ""),
                include_danmaku=bool(arguments.get("include_danmaku", True)),
                include_comments=bool(arguments.get("include_comments", True)),
                include_timestamps=bool(arguments.get("include_timestamps", False)),
                danmaku_limit=int(arguments.get("danmaku_limit", 500)),
                comment_limit=int(arguments.get("comment_limit", 30)),
            )
            return [TextContent(type="text", text=markdown)]

        if name == TOOL_SEARCH:
            videos = await bili_mod.search_videos(
                arguments.get("query", ""),
                limit=int(arguments.get("limit", 8)),
            )
            if not videos:
                return [TextContent(type="text", text="未找到相关视频。")]
            lines = ["# B站搜索结果", ""]
            for v in videos:
                lines.append(
                    f"## {v.get('title', '')}\n"
                    f"- **BV**：{v.get('bvid', '')}\n"
                    f"- **UP 主**：{v.get('author', '')}\n"
                    f"- **播放**：{v.get('play', 0):,} · **时长**：{v.get('duration', '')}\n"
                    f"- **简介**：{v.get('description', '')}\n"
                    f"- **链接**：https://www.bilibili.com/video/{v.get('bvid', '')}\n"
                )
            return [TextContent(type="text", text="\n".join(lines))]

        if name == TOOL_SCRIPT:
            script = await script_mod.generate_script(
                arguments.get("url", ""),
                style=arguments.get("style", "口播"),
                target_words=int(arguments.get("target_words", 800)),
                extra_hint=arguments.get("extra_hint", ""),
            )
            return [TextContent(type="text", text=script)]

        raise ValueError(f"未知工具: {name}")
    except Exception as exc:  # noqa: BLE001
        logger.error("%s 失败: %s", name, exc)
        return [TextContent(type="text", text=f"❌ {exc}")]


async def _run_server() -> None:
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options(),
        )


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
        stream=sys.stderr,
    )
    asyncio.run(_run_server())


if __name__ == "__main__":
    main()
