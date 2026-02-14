{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 9,
            "minor": 1,
            "revision": 2,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [ 820.0, 1007.0, 1000.0, 780.0 ],
        "boxes": [
            {
                "box": {
                    "id": "obj-39",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 454.0, 187.0, 39.0, 22.0 ],
                    "text": "click~"
                }
            },
            {
                "box": {
                    "id": "obj-38",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 464.0, 161.0, 29.5, 22.0 ],
                    "text": "1"
                }
            },
            {
                "box": {
                    "format": 6,
                    "id": "obj-36",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 833.0, 138.0, 50.0, 22.0 ]
                }
            },
            {
                "box": {
                    "format": 6,
                    "id": "obj-34",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 701.0, 121.0, 50.0, 22.0 ]
                }
            },
            {
                "box": {
                    "format": 6,
                    "id": "obj-12",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 243.0, 168.0, 50.0, 22.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-10",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 811.0, 182.0, 58.0, 22.0 ],
                    "text": "sig~ 0.01"
                }
            },
            {
                "box": {
                    "id": "obj-9",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 682.0, 182.0, 58.0, 22.0 ],
                    "text": "sig~ 0.15"
                }
            },
            {
                "box": {
                    "id": "obj-5",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 229.0, 225.0, 54.0, 22.0 ],
                    "text": "sig~ 100"
                }
            },
            {
                "box": {
                    "code": "// 1. Memory Allocation\nDelay s1(44100), s2(44100), s3(44100);\nDelay h_del(1000); // Small buffer for the strike position comb filter\n\n// 2. State Management\nHistory fb1(0), fb2(0), fb3(0);\nHistory lp1(0), lp2(0), lp3(0);\nHistory ax1(0), ay1(0), ax2(0), ay2(0), ax3(0), ay3(0);\nHistory h_env(0); \nHistory h_lp(0); \n\n// 3. Inputs\nf = in1; \nv = in2; \nstiff = in3; // Try 0.25 for that \"metallic\" piano stiffness\ndamp = in4;  // Try 0.05\n\n// 4. Calculations\nf1 = f; f2 = f * 1.0004; f3 = f * 0.9997;\nstiff_g = clip(stiff, 0, 0.98);\n\n// 5. The \"Felt\" Hammer Logic\ntrig = delta(v > 0) > 0;\n// Slower envelope decay simulates the hammer staying on the string longer\nh_env = trig ? v : h_env * 0.85; \n\n// Hammer LPF: Lower coef = softer felt. \n// This removes the \"snap\" of the attack.\nh_coef = 0.02 + (v * 0.08); \nh_raw = h_env + (noise() * h_env * 0.1);\nh_lp = h_lp + h_coef * (h_raw - h_lp);\n\n// 6. Strike Position (Comb Filtering)\n// Pianos hit at ~1/7th of the string. This cancels \"guitar-like\" harmonics.\nstrike_pos_samples = (samplerate/f1) / 7; \n// Using the Delay.read/write syntax for the hammer delay\nh_delayed = h_del.read(strike_pos_samples);\nh_del.write(h_lp);\nhammer_final = h_lp - h_delayed;\n\n// 7. Loss & Feedback Coefs\ndecay_mult = clip(0.999 - (damp * 0.2), 0.7, 0.999);\nlpf_c = clip(0.02 + (1-damp) * 0.15, 0.01, 0.4);\n\n// --- STRING 1 ---\nnode1 = fixdenorm(hammer_final + fb1);\nap1 = (stiff_g * ay1) + ax1 - (stiff_g * node1);\nax1 = node1; ay1 = ap1;\nl1 = lp1 + lpf_c * (ap1 - lp1);\nlp1 = l1;\nout_s1 = s1.read(samplerate/f1 - 1, interp=\"linear\");\ns1.write(l1);\nfb1 = out_s1 * decay_mult;\n\n// --- STRING 2 ---\nnode2 = fixdenorm(hammer_final + fb2);\nap2 = (stiff_g * ay2) + ax2 - (stiff_g * node2);\nax2 = node2; ay2 = ap2;\nl2 = lp2 + lpf_c * (ap2 - lp2);\nlp2 = l2;\nout_s2 = s2.read(samplerate/f2 - 1, interp=\"linear\");\ns2.write(l2);\nfb2 = out_s2 * decay_mult;\n\n// --- STRING 3 ---\nnode3 = fixdenorm(hammer_final + fb3);\nap3 = (stiff_g * ay3) + ax3 - (stiff_g * node3);\nax3 = node3; ay3 = ap3;\nl3 = lp3 + lpf_c * (ap3 - lp3);\nlp3 = l3;\nout_s3 = s3.read(samplerate/f3 - 1, interp=\"linear\");\ns3.write(l3);\nfb3 = out_s3 * decay_mult;\n\nout1 = (out_s1 + out_s2 + out_s3) * 0.33;",
                    "fontface": 0,
                    "fontname": "<Monospaced>",
                    "fontsize": 12.0,
                    "id": "obj-4",
                    "maxclass": "gen.codebox~",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 229.0, 301.0, 683.0, 329.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 0,
                    "patching_rect": [ 229.0, 644.0, 55.0, 22.0 ],
                    "text": "dac~ 1 2"
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [ "obj-4", 3 ],
                    "source": [ "obj-10", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 0 ],
                    "source": [ "obj-12", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-9", 0 ],
                    "source": [ "obj-34", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-10", 0 ],
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-39", 0 ],
                    "source": [ "obj-38", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-4", 1 ],
                    "source": [ "obj-39", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 1 ],
                    "order": 0,
                    "source": [ "obj-4", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 0 ],
                    "order": 1,
                    "source": [ "obj-4", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-4", 0 ],
                    "source": [ "obj-5", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-4", 2 ],
                    "source": [ "obj-9", 0 ]
                }
            }
        ],
        "autosave": 0
    }
}