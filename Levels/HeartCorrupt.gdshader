// MIT
// Copyright (c) 2026 Misza666

shader_type canvas_item;

uniform vec2 mouse_pos = vec2(0.22, 0.1);
uniform float zoom_level = 3.2;
uniform float scene_scale = 1.0;
uniform float eye_growth = 1.0;
uniform float showcase_materialize = 0.0;
uniform float showcase_spawn_shake = 0.0;
uniform float showcase_birth_wave = 0.0;

uniform float speed = 1.0;
uniform float power_base = 7.2;
uniform float power_amp = 0.34;
uniform float julia_strength = 0.22;
uniform float y_squash = 0.92;
uniform bool freeze_base_animation = false;
uniform bool freeze_shader_rotation = true;
uniform float rotation_speed = 1.0;
uniform bool use_dual = false;
uniform float rot_a = 0.8;
uniform float rot_b = 2.4;
uniform bool use_ferrofluid = true;
uniform float liquid_strength = 0.75;
uniform float liquid_speed = 2.15;

uniform int max_steps = 150;
uniform float surf_dist = 0.00032;
uniform int de_iterations = 12;

uniform float sub_bass = 0.0;
uniform float bass = 0.0;
uniform float kick = 0.0;
uniform float snare = 0.0;
uniform float air_hit = 0.0;
uniform float low_mids = 0.0;
uniform float mids = 0.0;
uniform float highs = 0.0;
uniform float energy = 0.0;
uniform float sub_bass_mult = 2.06;
uniform float bass_mult = 2.42;
uniform float kick_mult = 1.48;
uniform float low_mids_mult = 1.41;
uniform float mids_mult = 2.10;
uniform float highs_mult = 0.97;
uniform float energy_mult = 0.65;
uniform float reactivity_mult = 1.0;

uniform vec3 color_a = vec3(0.05, 0.37, 0.62);
uniform vec3 color_b = vec3(0.98, 0.68, 0.38);
uniform float color_mix = 0.28;
uniform float glow_strength = 0.30;
uniform float body_brightness = 0.78;

uniform bool use_orbit_light = true;
uniform float orbit_light_radius = 1.0;
uniform float orbit_light_height = 4.0;
uniform float orbit_light_speed = 2.0;
uniform float orbit_light_intensity = 8.0;
uniform vec3 orbit_light_color = vec3(0.98, 0.96, 0.92);

uniform bool use_god_eye = true;
uniform float eye_yaw = 0.98;
uniform float eye_pitch = -0.09;
uniform float eye_opening_radius = 0.36;
uniform float eye_throat_radius = 0.11;
uniform float eye_tunnel_front = 1.55;
uniform float eye_tunnel_back = -0.24;
uniform float eye_irregularity = 0.18;
uniform float eye_light_depth = -0.10;
uniform float god_eye_intensity = 4.8;
uniform float god_eye_power = 0.69;
uniform float voice_open_amount = 0.18;
uniform float voice_brightness = 2.4;
uniform float voice_opening_response = 0.30;
uniform float voice_throat_response = 0.42;
uniform float voice_irregularity_response = 0.42;
uniform float voice_depth_response = 0.11;
uniform float voice_tunnel_response = 0.14;
uniform float voice_fractal_warp = 0.55;
uniform float voice_fractal_detail = 0.34;
uniform float eye_cavity_flow = 1.0;
uniform float eye_cavity_color_flow = 0.90;
uniform float eye_cavity_ferro = 0.03;
uniform float voice_cavity_drive = 0.68;
uniform float voice_body_pulse = 0.02;
uniform float god_eye_pulse = 0.0;
uniform float god_eye_presence = 0.0;
uniform float god_eye_onset = 0.0;


vec3 rot_x(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(p.x, c*p.y - s*p.z, s*p.y + c*p.z);
}

vec3 rot_y(vec3 p, float a) {
    float c = cos(a), s = sin(a);
    return vec3(c*p.x + s*p.z, p.y, -s*p.x + c*p.z);
}

vec3 eye_axis() {
    float cp = cos(eye_pitch);
    return normalize(vec3(cp*sin(eye_yaw), sin(eye_pitch), cp*cos(eye_yaw)));
}

vec3 eye_basis(vec3 axis) {
    vec3 h = abs(axis.y) > 0.94 ? vec3(1.0,0.0,0.0) : vec3(0.0,1.0,0.0);
    return normalize(cross(axis, h));
}

vec3 eye_basis_u(vec3 axis) {
    return eye_basis(axis);
}

vec3 eye_origin() {
    return vec3(0.0, 0.09, 0.0);
}

float eye_talk_amount() {
    float pulse = clamp(god_eye_pulse, 0.0, 1.0);
    float presence = clamp(god_eye_presence, 0.0, 1.0);
    float onset = clamp(god_eye_onset, 0.0, 1.0);
    return clamp((pulse * 0.76 + presence * 0.24 + onset * 0.88) * god_eye_power, 0.0, 1.6);
}

vec3 eye_light_pos() {
    float pulse = clamp(god_eye_pulse, 0.0, 1.0);
    float onset = clamp(god_eye_onset, 0.0, 1.0);
    float eg = max(eye_growth, 0.001);
    float think = 0.5 + 0.5 * sin(TIME * 0.82 + pulse * 3.0 + onset * 5.0);
    float depth = eye_light_depth * eg + pulse * voice_depth_response * 0.35 * eg;
    depth += onset * voice_depth_response * 0.16 * eg + think * 0.020 * eg;
    return eye_origin() + eye_axis() * depth;
}

float eye_cavity_de(vec3 p, float t) {
    vec3 axis = eye_axis();
    vec3 rel = p - eye_origin();
    float axial = dot(rel, axis);

    vec3 bu = eye_basis_u(axis);
    vec3 bv = cross(axis, bu);
    float lx = dot(rel, bu);
    float ly = dot(rel, bv);
    float ang = atan(ly, lx);

    float pulse = clamp(god_eye_pulse, 0.0, 1.0);
    float presence = clamp(god_eye_presence, 0.0, 1.0);
    float onset = clamp(god_eye_onset, 0.0, 1.0);
    float talk = eye_talk_amount();
    float ferro = use_ferrofluid ? liquid_strength : 0.0;

    float eg = max(eye_growth, 0.0001);
    float front_pos = eye_tunnel_front * eg + pulse * voice_tunnel_response * 0.20 * eg + onset * voice_tunnel_response * 0.16 * eg;
    float back_pos = eye_tunnel_back * eg - pulse * voice_tunnel_response * 0.05 * eg;

    float span = max(front_pos - back_pos, 0.001);
    float along = clamp((axial - back_pos) / span, 0.0, 1.0);
    float flare = pow(along, 1.45);

    float music_eye = clamp((sub_bass*sub_bass_mult*0.22 + bass*bass_mult*0.18 + mids*mids_mult*0.12 + energy*energy_mult*0.18) * reactivity_mult, 0.0, 1.0);
    float talk_burst = clamp((pulse * 0.95 + onset * 1.25) * god_eye_power, 0.0, 2.20);
    float throat = eye_throat_radius * (1.0 + pulse * voice_throat_response * 0.45 + onset * voice_throat_response * 0.18 + music_eye * 0.025);
    float opening = eye_opening_radius * (1.0 + talk_burst * (voice_open_amount * 1.90 + voice_opening_response * 2.20) + presence * voice_opening_response * 0.06 + music_eye * 0.045);
    float radius = mix(throat, opening, flare);

    float warped_ang = ang;
    warped_ang += talk * voice_fractal_warp * 0.10 * sin(ang * 1.8 + axial * 2.6 + t * 0.08);
    warped_ang += presence * voice_fractal_warp * 0.04 * sin(ang * 3.2 - axial * 3.4 - t * 0.05);

    float ct = TIME * (0.70 + liquid_speed * 0.45 + ferro * 0.22);
    float music_flow_eye = clamp((mids*mids_mult*0.24 + low_mids*low_mids_mult*0.14 + highs*highs_mult*0.08) * reactivity_mult, 0.0, 1.0);
    float cavity_base_flow = eye_cavity_flow * (0.48 + ferro * eye_cavity_ferro * 0.90 + music_flow_eye * 0.10);
    float cavity_talk_flow = talk * voice_cavity_drive * god_eye_power;

    float base_wave_a = sin(warped_ang * 2.2 + axial * 3.1 + ct * 0.88);
    float base_wave_b = cos(warped_ang * 3.4 - axial * 4.2 - ct * 1.04);
    float base_wave_c = sin(axial * 5.4 + ct * 0.46);
    float talk_wave_a = sin(warped_ang * 2.8 + axial * 4.8 + ct * 1.42);
    float talk_wave_b = cos(warped_ang * 4.1 - axial * 5.2 - ct * 1.86);

    front_pos += cavity_base_flow * 0.06 * sin(ct * 0.56 + warped_ang * 1.8 + axial * 2.2);
    back_pos += cavity_base_flow * 0.03 * sin(ct * 0.38 - warped_ang * 2.1 - axial * 3.1);
    front_pos += cavity_talk_flow * 0.045 * sin(ct * 1.22 + axial * 3.9);

    float base_shape = cavity_base_flow * (0.12 * base_wave_a + 0.08 * base_wave_b + 0.05 * base_wave_c);
    float talk_shape = cavity_talk_flow * (0.18 * talk_wave_a + 0.12 * talk_wave_b);
    radius *= max(0.55, 1.0 + base_shape + talk_shape);

    float bite = onset * (0.11 + 0.07 * (0.5 + 0.5 * sin(warped_ang * 1.8 + axial * 4.0 + ct * 2.3)));
    radius *= max(0.38, 1.0 - bite);

    float irr_amt = eye_irregularity * eg * (1.0 + presence * voice_irregularity_response * 0.55 + onset * voice_irregularity_response * 0.20);
    float irr = 1.0;
    irr += irr_amt * 0.16 * sin(warped_ang * 2.4 + axial * 2.8 + ct * 0.30);
    irr += irr_amt * 0.10 * sin(warped_ang * 4.2 - axial * 2.0 - ct * 0.24);
    irr += cavity_base_flow * 0.08 * sin(warped_ang * 3.2 + axial * 4.2 + ct * 0.62);
    irr += cavity_talk_flow * 0.06 * sin(warped_ang * 4.8 - axial * 4.6 - ct * 0.94);
    radius *= max(irr, 0.72);

    vec2 cavity_xy = vec2(lx, ly);
    float swirl = cavity_base_flow * (0.010 + 0.014 * flare) + cavity_talk_flow * (0.010 + 0.012 * flare);
    cavity_xy += swirl * radius * vec2(
        sin(warped_ang * 2.6 + axial * 3.6 + ct * 0.94),
        cos(warped_ang * 2.2 - axial * 3.0 - ct * 0.82)
    );
    cavity_xy += cavity_base_flow * ferro * 0.010 * radius * vec2(
        cos(warped_ang * 4.2 - axial * 4.8 + ct * 1.28),
        sin(warped_ang * 3.6 + axial * 4.0 - ct * 1.12)
    );

    float radial = length(vec2(cavity_xy.x, cavity_xy.y * 1.06));
    float side = radial - radius;
    float back_cap = back_pos - axial;
    float front_cap = axial - front_pos;
    return max(side, max(back_cap, front_cap));
}

float eye_mouth_mask(vec3 p, float t) {
    vec3 axis = eye_axis();
    vec3 rel = p - eye_origin();
    float axial = dot(rel, axis);

    vec3 bu = eye_basis_u(axis);
    vec3 bv = cross(axis, bu);
    float lx = dot(rel, bu);
    float ly = dot(rel, bv);
    float radial = length(vec2(lx, ly * 1.06));

    float pulse = clamp(god_eye_pulse, 0.0, 1.0);
    float presence = clamp(god_eye_presence, 0.0, 1.0);
    float onset = clamp(god_eye_onset, 0.0, 1.0);

    float eg = max(eye_growth, 0.0001);
    float front_pos = eye_tunnel_front * eg + pulse * voice_tunnel_response * 0.20 * eg + onset * voice_tunnel_response * 0.16 * eg;
    float back_pos = eye_tunnel_back * eg - pulse * voice_tunnel_response * 0.05 * eg;
    float span = max(front_pos - back_pos, 0.001);
    float along = clamp((axial - back_pos) / span, 0.0, 1.0);
    float flare = pow(along, 1.45);

    float music_eye = clamp((sub_bass*sub_bass_mult*0.22 + bass*bass_mult*0.18 + mids*mids_mult*0.12 + energy*energy_mult*0.18) * reactivity_mult, 0.0, 1.0);
    float talk_burst = clamp((pulse * 0.95 + onset * 1.25) * god_eye_power, 0.0, 2.20);
    float throat = eye_throat_radius * (1.0 + pulse * voice_throat_response * 0.40 + music_eye * 0.020);
    float opening = eye_opening_radius * (1.0 + talk_burst * (voice_open_amount * 1.90 + voice_opening_response * 1.95) + presence * voice_opening_response * 0.05 + music_eye * 0.040);
    float radius = mix(throat, opening, flare);

    float radial_mask = 1.0 - smoothstep(radius * 0.96, radius * 1.18 + 0.016, radial);
    float axial_mask = smoothstep(back_pos - 0.03, back_pos + 0.05, axial) * (1.0 - smoothstep(front_pos + 0.01, front_pos + 0.16, axial));
    return clamp(radial_mask * axial_mask, 0.0, 1.0);
}

float bulb_de(vec3 p, float t) {
    float rm = reactivity_mult;
    float lt = t * liquid_speed;
    float ls = use_ferrofluid ? liquid_strength : 0.0;

    float sb = sub_bass * sub_bass_mult * rm;
    float b = bass * bass_mult * rm;
    float k = kick * kick_mult * rm;
    float lm = low_mids * low_mids_mult * rm;
    float m = mids * mids_mult * rm;
    float h = highs * highs_mult * rm;
    float sn = snare * rm;
    float ah = air_hit * rm;

    float low = clamp(sb * 0.58 + b * 0.42, 0.0, 1.8);
    float mid = clamp(lm * 0.46 + m * 0.54, 0.0, 1.8);
    float treble = clamp(h * 0.72 + ah * 0.28, 0.0, 1.6);
    float hit = clamp(k * 0.86 + sn * 0.34, 0.0, 1.6);

    float phase_a = lt * 0.23 + sin(lt * 0.071) * 0.62;
    float phase_b = lt * 0.31 + cos(lt * 0.053 + 1.7) * 0.48;
    float phase_c = lt * 0.17 + sin(lt * 0.097 + 2.4) * 0.36;

    float global_rot = freeze_shader_rotation ? 0.0 : lt * 0.080 * rotation_speed;
    p = rot_y(p, global_rot);

    vec3 wp = p;
    float low_warp = 0.036 * low;
    p += low_warp * vec3(
        sin(wp.y * 1.65 + wp.z * 1.10 + phase_a),
        cos(wp.z * 1.45 - wp.x * 1.05 + phase_b),
        sin(wp.x * 1.35 + wp.y * 1.25 + phase_c)
    );

    float mid_warp = 0.020 * ls + 0.034 * mid;
    vec3 mp = p;
    p += mid_warp * vec3(
        sin(mp.z * 2.30 + mp.y * 0.85 + phase_b),
        sin(mp.x * 2.10 - mp.z * 0.90 + phase_c + 1.4),
        cos(mp.y * 2.20 + mp.x * 0.95 + phase_a + 2.0)
    );

    float hit_warp = 0.050 * hit;
    vec3 hp = p;
    p += hit_warp * vec3(
        sin(hp.y * 3.0 + phase_b) * cos(hp.z * 2.2 - phase_c),
        -0.72 * sin(hp.x * 2.8 - phase_a) * cos(hp.z * 2.0),
        0.82 * cos(hp.y * 2.6 + phase_c) * sin(hp.x * 2.1 + phase_a)
    );

    p = rot_x(p, sin(phase_a) * 0.10 * ls);

    vec3 c = vec3(
        sin(t * 0.19) * cos(t * 0.13),
        cos(t * 0.17) * sin(t * 0.11),
        sin(t * 0.23 + 1.7)
    ) * julia_strength;

    c *= 1.0 + low * 0.48 + mid * 0.14;
    c += low * 0.052 * vec3(
        sin(phase_b * 0.72),
        cos(phase_a * 0.61 + 1.1),
        sin(phase_c * 0.83 + 2.0)
    );
    c += mid * 0.025 * vec3(
        cos(phase_a * 0.77 + 0.4),
        sin(phase_c * 0.69 + 2.2),
        cos(phase_b * 0.58 + 1.3)
    );
    c += hit * 0.018 * vec3(0.7, -0.5, 0.4);

    float power = power_base + power_amp * sin(t * 0.060);
    power += low * 0.075 - mid * 0.035 + hit * 0.018;
    power = clamp(power, 4.0, 10.0);

    float rot = 2.15;
    float ca = cos(rot);
    float sa = sin(rot);
    p = vec3(ca*p.x + sa*p.z, p.y, -sa*p.x + ca*p.z);

    vec3 z = p;
    float dr = 1.0;
    float r = 0.000001;
    float azimuth_power = floor(power_base + 0.5);

    for (int i = 0; i < 16; i++) {
        if (i >= de_iterations) break;

        r = max(length(z), 0.000001);
        if (r > 2.2) break;

        float fi = float(i);
        float theta = acos(clamp(z.z / r, -1.0, 1.0));
        float phi = atan(z.y, z.x);

        if (use_ferrofluid) {
            float wave_a = sin(lt*0.70 + fi*0.60 + r*4.50);
            float wave_b = cos(lt*0.55 + fi*0.90 + r*3.20);

            theta += wave_a * (0.125*ls + 0.078*low + 0.050*mid);
            phi   += wave_b * (0.145*ls + 0.050*low + 0.045*mid);
            theta += low * 0.082 * sin(phi*2.0 + fi*0.72 + phase_c*0.62);
            theta += mid * 0.072 * cos(phi*3.0 - fi*0.39 - phase_a*0.42);
            phi   += mid * 0.060 * cos(theta*2.0 - fi*0.61 - phase_b*0.38);
            theta += hit * 0.060 * sin(phi*4.0 + fi*1.15 + phase_b*0.30);
            phi   -= hit * 0.038 * cos(theta*3.0 - fi*0.90 - phase_a*0.27);
            theta += treble * 0.030 * sin(phi*6.0 + r*7.0 + fi*1.30 + phase_c);
            phi   += treble * 0.026 * sin(r*10.0 + fi*1.90 + phase_b*1.25);
        }

        dr = pow(r, power - 1.0) * power * dr + 1.0;
        float zr = pow(r, power);
        theta *= power;
        phi *= azimuth_power;

        vec3 nz = zr * vec3(
            sin(theta)*cos(phi),
            sin(theta)*sin(phi),
            cos(theta)
        );

        if (use_ferrofluid) {
            float flow_amp = 0.080 * ls + 0.014 * mid;
            nz = rot_y(nz, flow_amp * sin(lt*0.60 + fi*0.80));
            nz = rot_x(nz, flow_amp * 0.68 * cos(lt*0.70 - fi*1.00));
        }

        z = nz + p + c;
    }

    r = max(r, 0.000001);
    return 0.5 * log(r) * r / max(dr, 0.000001);
}

float fractal_map(vec3 p, float t) {
    float pulse = clamp(god_eye_pulse, 0.0, 1.0);
    float onset = clamp(god_eye_onset, 0.0, 1.0);
    float voice_scale = 1.0 + voice_body_pulse * (pulse*0.9 + onset*0.35);
    vec3 q = p / voice_scale;
    q.y *= y_squash;
    return bulb_de(q, t) * voice_scale;
}

vec2 scene_map(vec3 p, float t) {
    float s = max(scene_scale, 0.0001);
    vec3 q = p / s;

    float matz = clamp(showcase_materialize, 0.0, 1.0);
    if (matz > 0.001) {
        vec3 stretch = vec3(0.76 + 0.08*sin(TIME*2.1), 1.28 + 0.12*cos(TIME*1.7), 0.82);
        q /= mix(vec3(1.0), stretch, matz);
        q += matz * 0.035 * vec3(
            sin(q.y*2.6 + TIME*2.2),
            sin(q.z*2.2 - TIME*1.8),
            cos(q.x*2.5 + TIME*2.0)
        );
    }

    float shake = clamp(showcase_spawn_shake, 0.0, 1.0);
    q += shake * vec3(sin(TIME*26.0)*0.020, cos(TIME*31.0)*0.018, sin(TIME*23.0)*0.020);

    float birth = clamp(showcase_birth_wave, 0.0, 1.0);
    if (birth > 0.001) {
        float qr = max(length(q), 0.001);
        vec3 qn = q / qr;
        float wave = sin(qr*10.0 - TIME*7.0) * 0.040;
        float shear = sin(q.y*5.0 + TIME*4.0) * 0.018;
        q += qn * wave * birth;
        q.x += shear * birth;
        q.z -= shear * birth * 0.65;
    }

    float body = fractal_map(q, t) * s;
    if (!use_god_eye) return vec2(body, 0.0);
    float cut = -eye_cavity_de(q, t) * s;
    return vec2(max(body, cut), step(body, cut));
}

float map_only(vec3 p, float t) {
    return scene_map(p, t).x;
}


float eye_visibility(vec3 p, vec3 light_pos, float t) {
    vec3 to_light = light_pos - p;
    float total = length(to_light);
    if (total < 0.015) return 1.0;

    vec3 rd = to_light / total;
    float tt = 0.012;
    float vis = 1.0;
    for (int i = 0; i < 9; i++) {
        if (tt >= total - 0.015) break;
        float d = map_only(p + rd * tt, t);
        if (d < surf_dist * 1.8) {
            vis = 0.0;
            break;
        }
        tt += clamp(d * 0.70, 0.010, 0.090);
    }
    return vis;
}

vec3 normal_fast(vec3 p, float t) {
    float e = 0.00032;
    return normalize(vec3(
        map_only(p + vec3(e,0.0,0.0), t) - map_only(p - vec3(e,0.0,0.0), t),
        map_only(p + vec3(0.0,e,0.0), t) - map_only(p - vec3(0.0,e,0.0), t),
        map_only(p + vec3(0.0,0.0,e), t) - map_only(p - vec3(0.0,0.0,e), t)
    ));
}

float ao_fast(vec3 p, vec3 n, float t) {
    float occ = 0.0;
    float w = 1.0;
    for (int i = 0; i < 5; i++) {
        float d = 0.016 + 0.032 * float(i);
        float h = map_only(p + n * d, t);
        occ += (d - h) * w;
        w *= 0.55;
    }
    return clamp(1.0 - occ * 4.2, 0.22, 1.0);
}

float softshadow_fast(vec3 ro, vec3 rd, float tmax, float t) {
    float res = 1.0;
    float dist = 0.020;
    for (int i = 0; i < 24; i++) {
        if (dist >= tmax) break;
        float h = map_only(ro + rd * dist, t);
        if (h < 0.00020) return 0.0;
        res = min(res, 16.0 * h / dist);
        dist += clamp(h, 0.004, 0.090);
    }
    return clamp(res, 0.0, 1.0);
}


vec3 surface_col(vec3 p, vec3 n, float t) {
    float rm = reactivity_mult;
    float sb = sub_bass * sub_bass_mult * rm;
    float b = bass * bass_mult * rm;
    float k = kick * kick_mult * rm;
    float lm = low_mids * low_mids_mult * rm;
    float m = mids * mids_mult * rm;
    float h = highs * highs_mult * rm;
    float e = energy * energy_mult * rm;
    float sn = snare * rm;
    float ah = air_hit * rm;

    float color_drive = clamp(e * 0.44 + m * 0.26 + h * 0.18 + b * 0.12, 0.0, 1.5);
    float warm_drive = clamp(sb * 0.22 + b * 0.30 + e * 0.34 + k * 0.10, 0.0, 1.5);
    float sparkle = clamp(h * 0.55 + ah * 0.32 + sn * 0.16, 0.0, 1.5);

    float phase = length(p)*0.22 + t*0.10;
    phase += color_drive * 0.035 * sin(t * 0.37 + p.y * 2.2);
    vec3 col = 0.5 + 0.5*cos(TAU*(color_a + phase + n.y*0.4));

    float dynamic_mix = clamp(color_mix + warm_drive * 0.10 + m * 0.05 - h * 0.025, 0.0, 1.0);
    col = mix(col, color_b, dynamic_mix + 0.08*sin(t*0.22 + p.x*2.0 + m*0.7));
    col *= (0.62 + 0.28*n.y) * body_brightness * (1.0 + e * 0.10 + sb * 0.04);
    col += 0.055*cos(vec3(2.8,5.2,7.1)*phase + t*0.28);

    col += glow_strength * vec3(0.72, 0.38, 0.16) * (e * 0.55 + b * 0.18 + m * 0.12 + k * 0.12);
    col += vec3(0.32, 0.48, 0.72) * sparkle * 0.055 * (0.5 + 0.5*sin(t*1.7 + p.z*8.0));
    col += vec3(1.0, 0.78, 0.42) * (k * 0.055 + sn * 0.035);
    return max(col, vec3(0.0));
}

vec3 cavity_surface_col(vec3 p, vec3 n, vec3 rd, float t, float visibility) {
    vec3 lp = eye_light_pos();
    float ld = length(p - lp);
    float pulse = clamp(god_eye_pulse, 0.0, 1.0);
    float presence = clamp(god_eye_presence, 0.0, 1.0);
    float onset = clamp(god_eye_onset, 0.0, 1.0);
    float talk = eye_talk_amount();
    float ferro = use_ferrofluid ? liquid_strength : 0.0;

    float attenuation = 1.0 / (0.075 + ld*ld*2.2);
    float heat = clamp(attenuation * 0.34, 0.0, 1.0);
    heat = pow(heat, 0.72);

    float ct = TIME * (0.84 + eye_cavity_color_flow * 0.64 + ferro * 0.24);
    float molten = 0.5 + 0.5 * sin(ct + p.x * 8.2 + p.y * 7.1 + p.z * 8.7 + ld * 6.4);
    float molten2 = 0.5 + 0.5 * sin(ct * 0.63 - p.x * 5.4 + p.y * 8.8 - p.z * 4.9);
    float molten3 = 0.5 + 0.5 * sin(ct * 1.27 + p.x * 11.0 - p.y * 6.2 + p.z * 9.4);
    float color_wave = clamp(molten * 0.44 + molten2 * 0.28 + molten3 * 0.28, 0.0, 1.0);

    vec3 ember = vec3(0.24, 0.010, 0.001);
    vec3 orange = vec3(1.0, 0.105, 0.003);
    vec3 gold = vec3(1.0, 0.50, 0.025);
    vec3 white_hot = vec3(1.0, 0.98, 0.78);

    float hotness = clamp(heat * 0.42 + color_wave * eye_cavity_color_flow * (0.60 + talk * 0.34) + pulse * 0.12 + onset * 0.16, 0.0, 1.0);
    float orange_bias = clamp(1.0 - hotness * 1.05 + (1.0 - pulse) * 0.12, 0.0, 1.0);
    vec3 warm_band = mix(orange, gold, smoothstep(0.18, 0.56, hotness));
    vec3 col = mix(ember, warm_band, smoothstep(0.04, 0.24, heat));
    col = mix(col, white_hot, smoothstep(0.76, 0.98, hotness));
    col = mix(col, orange, orange_bias * 0.28);

    float facing = pow(clamp(dot(n, normalize(lp - p)), 0.0, 1.0), 0.55);
    float think_pulse = 0.82 + 0.18 * sin(TIME * 1.15 + ld * 7.0 + pulse * 2.0);
    float music_eye_glow = clamp((energy*energy_mult*0.34 + bass*bass_mult*0.16 + highs*highs_mult*0.14 + kick*kick_mult*0.12) * reactivity_mult, 0.0, 1.0);
    float voice_gain = 0.72 + pulse*voice_brightness*god_eye_power + onset*1.35*god_eye_power + presence*0.35*god_eye_power;
    col *= god_eye_intensity * god_eye_power * voice_gain * (1.0 + music_eye_glow * 0.28) * think_pulse * (0.25 + 0.75*visibility) * (0.42 + 0.58*facing);

    float fres = pow(1.0 - max(dot(n, -rd), 0.0), 2.0);
    vec3 rim_col = mix(gold, orange, 0.5 + 0.5*sin(ct * 0.91 + p.x * 8.0 - p.y * 6.0 + p.z * 5.0));
    col += rim_col * fres * (0.24 + presence*0.48 + color_wave*0.24 + talk*0.16) * god_eye_intensity;
    return col;
}

vec3 add_visible_external_sun(vec3 col, vec3 ro, vec3 rd, vec3 light_pos, vec3 light_color, float intensity) {
    vec3 ldir = normalize(light_pos - ro);
    float facing = max(dot(rd, ldir), 0.0);
    float sun_disc = pow(facing, 1200.0);
    float sun_core = pow(facing, 180.0);
    float sun_glow = pow(facing, 20.0);
    col += light_color * (sun_disc * 3.6 + sun_core * 0.45 + sun_glow * 0.10) * intensity;
    return col;
}

vec3 external_point_light(
    vec3 albedo,
    vec3 p,
    vec3 n,
    vec3 rd,
    vec3 light_pos,
    vec3 light_color,
    float intensity,
    float visibility
) {
    vec3 to_light = light_pos - p;
    float light_dist = max(length(to_light), 0.0001);
    vec3 ldir = to_light / light_dist;
    vec3 vdir = normalize(-rd);
    vec3 hdir = normalize(ldir + vdir);

    float ndotl_raw = dot(n, ldir);
    float ndotl = max(ndotl_raw, 0.0);
    float wrapped_diff = clamp((ndotl_raw + 0.14) / 1.14, 0.0, 1.0);
    float ndotv = max(dot(n, vdir), 0.0);
    float ndoth = max(dot(n, hdir), 0.0);
    float vdoth = max(dot(vdir, hdir), 0.0);

    float roughness = 0.36;
    float alpha = roughness * roughness;
    float a2 = alpha * alpha;
    float denom = ndoth * ndoth * (a2 - 1.0) + 1.0;
    float distribution = a2 / max(3.14159265 * denom * denom, 0.0001);
    float k = (roughness + 1.0);
    k = (k * k) * 0.125;
    float gv = ndotv / max(ndotv * (1.0 - k) + k, 0.0001);
    float gl = ndotl / max(ndotl * (1.0 - k) + k, 0.0001);
    float geometry = gv * gl;
    vec3 f0 = mix(vec3(0.035), max(albedo, vec3(0.0)), 0.075);
    vec3 fresnel = f0 + (vec3(1.0) - f0) * pow(1.0 - vdoth, 5.0);
    vec3 specular = distribution * geometry * fresnel / max(4.0 * ndotv * ndotl + 0.001, 0.001);

    vec3 diffuse = albedo * (vec3(1.0) - fresnel) * wrapped_diff / 3.14159265;
    float attenuation = intensity / (0.55 + light_dist * light_dist * 0.070);
    float ridge_fill = pow(1.0 - ndotv, 2.0) * 0.055;

    vec3 result = (diffuse * light_color * 3.15 + specular * light_color * 2.25) * attenuation * visibility;
    result += albedo * light_color * ridge_fill * attenuation * visibility;
    return result;
}

vec3 eye_light_fast(vec3 p, vec3 n) {
    float eg = max(eye_growth, 0.001);
    vec3 lp = vec3(0.0, 0.09, 0.0) + eye_axis() * (eye_light_depth * eg);
    vec3 lv = lp - p;
    float d2 = max(dot(lv, lv), 0.02);
    vec3 ld = normalize(lv);
    float facing = max(dot(n, ld), 0.0);
    float pulse = clamp(god_eye_pulse + god_eye_onset*0.55, 0.0, 1.4);
    float gain = god_eye_intensity * god_eye_power * (0.18 + pulse*0.28);
    vec3 warm = mix(vec3(1.0,0.08,0.003), vec3(1.0,0.62,0.08), clamp(0.35 + pulse*0.35, 0.0, 1.0));
    return warm * facing * gain / (1.0 + d2*7.0);
}

void fragment() {
    vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 uv = (FRAGCOORD.xy - 0.5*res) / res.y;
    float t = freeze_base_animation ? 0.0 : TIME * speed;

    float yaw = mouse_pos.x * TAU;
    float pitch = mouse_pos.y * 1.4;
    vec3 target = vec3(0.0, 0.15, 0.0);
    float cam_dist = 2.8 * zoom_level;
    vec3 ro = target + cam_dist * vec3(cos(pitch)*sin(yaw), sin(pitch), cos(pitch)*cos(yaw));
    vec3 fw = normalize(target - ro);
    vec3 rt = normalize(cross(fw, vec3(0.0,1.0,0.0)));
    vec3 up = cross(rt, fw);
    vec3 rd = normalize(uv.x*rt + uv.y*up + 1.65*fw);

    float travel = 0.0;
    bool hit = false;
    vec2 hit_info = vec2(0.0);
    vec3 hp = ro;

    for (int i = 0; i < 220; i++) {
        if (i >= max_steps) break;
        hp = ro + rd*travel;
        hit_info = scene_map(hp, t);
        float d = hit_info.x;
        if (d < surf_dist) { hit = true; break; }
        travel += max(d*0.72, 0.0010);
        if (travel > 14.0) break;
    }

    vec3 col = vec3(0.0);
    vec3 orbit_pos = vec3(
        sin(TIME*orbit_light_speed)*orbit_light_radius,
        -orbit_light_height,
        cos(TIME*orbit_light_speed)*orbit_light_radius
    );

    if (hit) {
        vec3 n = normal_fast(hp, t);
        float ao = ao_fast(hp, n, t);
        vec3 light_dir = normalize(vec3(0.55, 0.8, 0.35));
        float shadow = softshadow_fast(hp + n * 0.010, light_dir, 1.6, t);
        float diff = 0.12 + 0.88 * max(dot(n, light_dir), 0.0) * shadow;
        float rim = pow(1.0 - max(dot(n, -rd), 0.0), 2.2);
        vec3 halfv = normalize(light_dir - rd);
        float spec = pow(max(dot(n, halfv), 0.0), 34.0) * shadow;

        if (hit_info.y > 0.5) {
            vec3 lp = eye_light_pos();
            float eye_vis = eye_visibility(hp, lp, t);
            col = cavity_surface_col(hp, n, rd, t, eye_vis);
            if (use_orbit_light) {
                col += external_point_light(vec3(0.55), hp, n, rd, orbit_pos, orbit_light_color, orbit_light_intensity, 1.0) * 0.42;
            }
        } else {
            vec3 albedo = surface_col(hp, n, t);
            col = albedo * diff * ao * 1.05;
            col += albedo * rim * glow_strength * (0.58 + 0.24 * ao);
            col += vec3(1.0) * spec * 0.28;

            if (use_orbit_light) {
                col += external_point_light(albedo, hp, n, rd, orbit_pos, orbit_light_color, orbit_light_intensity, 1.0);
            }

            if (use_god_eye && eye_light_depth < 0.0) {
                vec3 lp = eye_light_pos();
                float eye_vis = eye_visibility(hp, lp, t);
                float mouth = eye_mouth_mask(hp, t);
                if (mouth > 0.0001 && eye_vis > 0.0) {
                    float ndl = max(dot(n, normalize(lp - hp)), 0.0);
                    float eye_att = god_eye_intensity * god_eye_power / (1.0 + dot(lp - hp, lp - hp) * 3.0);
                    col += mix(vec3(1.0, 0.12, 0.03), vec3(1.0, 0.62, 0.08), 0.45) * ndl * eye_att * mouth * eye_vis * 0.85;
                }
            }
        }
    }

    if (use_orbit_light) {
        col = add_visible_external_sun(col, ro, rd, orbit_pos, orbit_light_color, orbit_light_intensity * 0.38);
    }

    col = col / (1.0 + col*0.20);
    col = pow(max(col, vec3(0.0)), vec3(0.88));
    COLOR = vec4(col, 1.0);

}