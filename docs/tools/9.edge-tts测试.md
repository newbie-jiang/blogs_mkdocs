## edge_tts测试

官方文档：https://github.com/rany2/edge-tts

依赖库

```
pip install edge-tts sounddevice soundfile numpy
```

快速测试

```
edge-playback --text "Hello, world!"
```

查找中文音色，并读取文字自动播放

```python
import edge_tts
import asyncio
import time
import io
import sys
import numpy as np
import sounddevice as sd
import soundfile as sf

TEXT = "你好，这是一段音色试听示例。支持多种声音风格，你可以选择喜欢的声音。"

async def list_zh_voices():
    voices = await edge_tts.list_voices()
    zh_voices = [v for v in voices if v["Locale"].startswith("zh-")]
    return zh_voices

async def main():
    voices = await list_zh_voices()
    print(f"共找到 {len(voices)} 个中文音色\n")
    for idx, v in enumerate(voices):
        name = v.get("ShortName")
        gender = v.get("Gender", "?")
        display_name = v.get("DisplayName") or v.get("FriendlyName") or v.get("ShortName")
        voice_type = v.get("VoiceType", "?")
        style_list = v.get("StyleList", [])
        locale = v.get("Locale", "?")
        # 打印详细音色信息
        print(f"\n[{idx+1}/{len(voices)}] 试听人物: {display_name}")
        print(f"  - 技术名: {name}")
        print(f"  - 性别: {gender}")
        print(f"  - 类型: {voice_type}")
        print(f"  - 语言: {locale}")
        print(f"  - 风格: {', '.join(style_list) if style_list else '无'}")

        try:
            communicate = edge_tts.Communicate(TEXT, voice=name)
            # 获取生成的音频流
            audio_bytes = b''
            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    audio_bytes += chunk["data"]

            # 使用 soundfile 和 sounddevice 播放内存中的 wav
            audio_buffer = io.BytesIO(audio_bytes)
            data, samplerate = sf.read(audio_buffer, dtype='float32')
            print("合成完毕，准备播放...")
            sd.play(data, samplerate)
            sd.wait()
            print("播放完成。")
        except Exception as e:
            print(f"音色 {name} 合成或播放失败: {e}")
        time.sleep(1)  # 每段之间停1秒

asyncio.run(main())

```

![image-20250713193026471](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250713193026471.png)