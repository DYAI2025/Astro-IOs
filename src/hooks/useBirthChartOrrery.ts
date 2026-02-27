// Simplified hook for the birth chart orrery visualization.
// Shows planets frozen at a specific birth date, with optional slow rotation.

import { useState, useRef, useCallback } from "react";
import * as THREE from "three";
import { daysSinceJ2000 } from "../lib/astronomy/calculations";

export interface UseBirthChartOrreryReturn {
  simTime: number;
  isPlaying: boolean;
  speed: number;
  setIsPlaying: (playing: boolean) => void;
  setSpeed: (speed: number) => void;
  setSimTime: (t: number | ((prev: number) => number)) => void;
  sceneRef: React.MutableRefObject<THREE.Scene | null>;
  cameraRef: React.MutableRefObject<THREE.Camera | null>;
  rendererRef: React.MutableRefObject<THREE.WebGLRenderer | null>;
}

export function useBirthChartOrrery(
  birthDate: Date,
): UseBirthChartOrreryReturn {
  const [simTime, setSimTime] = useState(() => daysSinceJ2000(birthDate));
  const [isPlaying, setIsPlaying] = useState(false); // Start paused
  const [speed, setSpeed] = useState(86400);

  const sceneRef = useRef<THREE.Scene | null>(null);
  const cameraRef = useRef<THREE.Camera | null>(null);
  const rendererRef = useRef<THREE.WebGLRenderer | null>(null);

  return {
    simTime,
    isPlaying,
    speed,
    setIsPlaying,
    setSpeed,
    setSimTime,
    sceneRef,
    cameraRef,
    rendererRef,
  };
}
