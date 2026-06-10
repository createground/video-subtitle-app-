import {
  AbsoluteFill,
  OffthreadVideo,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export type SubtitleSegment = {
  start: number;
  end: number;
  text: string;
};

type Props = {
  videoSrc: string;
  subtitles: SubtitleSegment[];
};

const SubtitleText: React.FC<{ text: string }> = ({ text }) => {
  return (
    <div
      style={{
        position: "absolute",
        bottom: 80,
        left: "50%",
        transform: "translateX(-50%)",
        width: "85%",
        textAlign: "center",
      }}
    >
      <span
        style={{
          display: "inline",
          backgroundColor: "rgba(0, 0, 0, 0.72)",
          color: "#ffffff",
          fontSize: 48,
          fontWeight: 700,
          lineHeight: 1.6,
          padding: "6px 16px",
          borderRadius: 6,
          boxDecorationBreak: "clone",
          WebkitBoxDecorationBreak: "clone",
          fontFamily:
            '"Noto Sans JP", "Hiragino Kaku Gothic ProN", "Meiryo", sans-serif',
          letterSpacing: "0.02em",
          textShadow: "0 2px 4px rgba(0,0,0,0.5)",
        }}
      >
        {text}
      </span>
    </div>
  );
};

export const SubtitleVideo: React.FC<Props> = ({ videoSrc, subtitles }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const currentTimeSec = frame / fps;

  const activeSegment = subtitles.find(
    (seg) => currentTimeSec >= seg.start && currentTimeSec < seg.end
  );

  return (
    <AbsoluteFill>
      <OffthreadVideo src={staticFile(videoSrc)} />
      {activeSegment && <SubtitleText text={activeSegment.text} />}
    </AbsoluteFill>
  );
};
