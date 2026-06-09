import React from "react";
import { Composition } from "remotion";
import { SubtitleVideo, SubtitleSegment } from "./SubtitleVideo";
import subtitleData from "./subtitles.json";

const subtitles: SubtitleSegment[] = subtitleData as SubtitleSegment[];

const lastSeg = subtitles[subtitles.length - 1];
const durationSec = lastSeg ? lastSeg.end + 1 : 10;
const FPS = 30;

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="SubtitleVideo"
      component={SubtitleVideo}
      durationInFrames={Math.ceil(durationSec * FPS)}
      fps={FPS}
      width={1920}
      height={1080}
      defaultProps={{
        videoSrc: "./input.mp4",
        subtitles,
      }}
    />
  );
};
