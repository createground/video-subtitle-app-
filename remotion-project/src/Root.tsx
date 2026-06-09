import {Composition} from 'remotion';

export const RemotionRoot: React.FC = () => {
	return (
		<>
			<Composition
				id="MyComposition"
				component={() => <div />}
				durationInFrames={60}
				fps={30}
				width={1280}
				height={720}
			/>
		</>
	);
};
