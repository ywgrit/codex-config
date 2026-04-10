# Global AGENTS Instructions

- 对 GitHub 问题排查与实现工作，优先使用 `gh` 工具进行搜索与查看（例如 `gh issue view`, `gh search issues`），再进行代码修改。
- 对网站读取、浏览器自动化、桌面应用自动化，以及 `opencli list` 中已存在的站点/应用能力，优先使用 `opencli`，不要先手写临时脚本或直接猜测页面结构。
- 在未得到用户明确同意前，只允许使用 `opencli` 的只读、无副作用命令；禁止执行任何会发布、发送、上传、编辑、删除、点赞、评论、下单或修改远端状态的命令。
- 当 `opencli` 命令失败且看起来是适配器问题时，优先开启 `OPENCLI_DIAGNOSTIC=1` 收集诊断信息，并按已安装的 `opencli-autofix` / `opencli-explorer` skill 流程处理。
