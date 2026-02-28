// Advanced materials & shaders for the CelestialOrrery visualization

import * as THREE from "three";

/** Animated sun material with corona and surface details */
export function createSunMaterial(): THREE.ShaderMaterial {
  return new THREE.ShaderMaterial({
    uniforms: {
      time: { value: 0 },
      color1: { value: new THREE.Color("#FFF5E0") },
      color2: { value: new THREE.Color("#FFD700") },
      color3: { value: new THREE.Color("#FFA500") },
    },
    vertexShader: `
      varying vec2 vUv;
      varying vec3 vNormal;
      varying vec3 vPosition;
      void main() {
        vUv = uv;
        vNormal = normalize(normalMatrix * normal);
        vPosition = position;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      uniform float time;
      uniform vec3 color1;
      uniform vec3 color2;
      uniform vec3 color3;
      varying vec2 vUv;
      varying vec3 vNormal;
      varying vec3 vPosition;
      float random(vec2 st) {
        return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
      }
      float noise(vec2 st) {
        vec2 i = floor(st);
        vec2 f = fract(st);
        float a = random(i);
        float b = random(i + vec2(1.0, 0.0));
        float c = random(i + vec2(0.0, 1.0));
        float d = random(i + vec2(1.0, 1.0));
        vec2 u = f * f * (3.0 - 2.0 * f);
        return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
      }
      void main() {
        vec2 noiseCoord = vUv * 8.0 + time * 0.05;
        float n = noise(noiseCoord);
        float n2 = noise(noiseCoord * 2.0 + vec2(time * 0.03, 0.0));
        float rim = 1.0 - abs(dot(vNormal, vec3(0, 0, 1)));
        rim = pow(rim, 2.0);
        vec3 surfaceColor = mix(color1, color2, n * 0.5 + 0.5);
        surfaceColor = mix(surfaceColor, color3, n2 * 0.3);
        float spots = step(0.85, n);
        surfaceColor += vec3(1.0, 0.9, 0.7) * spots * 0.3;
        surfaceColor += vec3(1.0, 0.6, 0.2) * rim * 0.5;
        gl_FragColor = vec4(surfaceColor, 1.0);
      }
    `,
  });
}

/** Enhanced planet material with emissive glow */
export function createPlanetMaterial(
  color: string,
  emissiveIntensity: number = 0.1,
  roughness: number = 0.7,
  metalness: number = 0.1,
): THREE.MeshStandardMaterial {
  return new THREE.MeshStandardMaterial({
    color: new THREE.Color(color),
    roughness,
    metalness,
    emissive: new THREE.Color(color),
    emissiveIntensity,
  });
}

/** Atmospheric glow shader (Fresnel effect) */
export function createAtmosphereShader(
  color: string,
  glowIntensity: number = 0.8,
): THREE.ShaderMaterial {
  return new THREE.ShaderMaterial({
    uniforms: {
      color: { value: new THREE.Color(color) },
      intensity: { value: glowIntensity },
    },
    vertexShader: `
      varying vec3 vNormal;
      varying vec3 vPosition;
      void main() {
        vNormal = normalize(normalMatrix * normal);
        vPosition = (modelViewMatrix * vec4(position, 1.0)).xyz;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      uniform vec3 color;
      uniform float intensity;
      varying vec3 vNormal;
      varying vec3 vPosition;
      void main() {
        vec3 viewDir = normalize(-vPosition);
        float rim = 1.0 - max(0.0, dot(viewDir, vNormal));
        rim = pow(rim, 3.0);
        vec3 glowColor = color * rim * intensity;
        float alpha = rim * intensity * 0.6;
        gl_FragColor = vec4(glowColor, alpha);
      }
    `,
    transparent: true,
    side: THREE.BackSide,
    blending: THREE.AdditiveBlending,
    depthWrite: false,
  });
}

/** Saturn's rings with Cassini division */
export function createSaturnRingsMaterial(): THREE.ShaderMaterial {
  return new THREE.ShaderMaterial({
    uniforms: {
      innerRadius: { value: 1.4 },
      outerRadius: { value: 2.2 },
    },
    vertexShader: `
      varying vec2 vUv;
      varying vec3 vPosition;
      void main() {
        vUv = uv;
        vPosition = position;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      uniform float innerRadius;
      uniform float outerRadius;
      varying vec2 vUv;
      varying vec3 vPosition;
      float random(vec2 st) {
        return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
      }
      void main() {
        vec2 center = vUv - 0.5;
        float dist = length(center) * 2.0;
        float bands = sin(dist * 60.0) * 0.5 + 0.5;
        float bands2 = sin(dist * 120.0 + 0.5) * 0.3 + 0.7;
        float cassini = smoothstep(0.73, 0.75, dist) * (1.0 - smoothstep(0.75, 0.77, dist));
        vec3 ringColor = vec3(0.85, 0.77, 0.65);
        ringColor *= bands * bands2;
        ringColor *= 1.0 - cassini * 0.7;
        float noise = random(vUv * 100.0) * 0.15;
        ringColor += noise;
        float edgeFade = smoothstep(0.0, 0.1, dist) * (1.0 - smoothstep(0.9, 1.0, dist));
        float opacity = 0.85 * bands * bands2 * edgeFade;
        opacity *= 1.0 - cassini * 0.5;
        gl_FragColor = vec4(ringColor, opacity);
      }
    `,
    transparent: true,
    side: THREE.DoubleSide,
    depthWrite: false,
  });
}

/** Milky Way background star field */
export function createMilkyWayBackground(scene: THREE.Scene): void {
  const milkyWayGeo = new THREE.BufferGeometry();
  const positions: number[] = [];
  const colors: number[] = [];

  for (let i = 0; i < 15000; i++) {
    const theta = Math.random() * Math.PI * 2;
    let phi = Math.acos(2 * Math.random() - 1);

    const bandHeight = 0.3;
    if (Math.random() > 0.3) {
      phi = Math.PI / 2 + (Math.random() - 0.5) * bandHeight;
    }

    const r = 450 + Math.random() * 100;
    positions.push(
      r * Math.sin(phi) * Math.cos(theta),
      r * Math.sin(phi) * Math.sin(theta),
      r * Math.cos(phi),
    );

    const color = new THREE.Color();
    const hue = 0.55 + Math.random() * 0.15;
    const sat = 0.1 + Math.random() * 0.2;
    const light = 0.7 + Math.random() * 0.3;
    color.setHSL(hue, sat, light);
    colors.push(color.r, color.g, color.b);
  }

  milkyWayGeo.setAttribute("position", new THREE.Float32BufferAttribute(positions, 3));
  milkyWayGeo.setAttribute("color", new THREE.Float32BufferAttribute(colors, 3));

  const milkyWayMat = new THREE.PointsMaterial({
    size: 1.2,
    vertexColors: true,
    transparent: true,
    opacity: 0.8,
    sizeAttenuation: true,
    blending: THREE.AdditiveBlending,
    depthWrite: false,
  });

  scene.add(new THREE.Points(milkyWayGeo, milkyWayMat));
}

/** Updates animated materials (call in animation loop) */
export function updateMaterials(delta: number, sunMaterial?: THREE.ShaderMaterial): void {
  if (sunMaterial?.uniforms.time) {
    sunMaterial.uniforms.time.value += delta;
  }
}
