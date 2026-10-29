#include <Arduino.h>

// บอร์ด NodeMCU มี LED ติดมากับบอร์ดเชื่อมอยู่ที่ขา D4 (GPIO2)
#ifndef LED_BUILTIN
  #define LED_BUILTIN 2
#endif

// ฟังก์ชันช่วยยิงจังหวะไฟ (เปิด-ปิด พร้อมแสดงผลทาง Serial Monitor)
void beat(int onTime, int offTime, const char* sound) {
  digitalWrite(LED_BUILTIN, LOW);   // เปิดไฟ (NodeMCU เป็น Active LOW)
  Serial.print("LED: ON  -> ");
  Serial.println(sound);
  delay(onTime);

  digitalWrite(LED_BUILTIN, HIGH);  // ปิดไฟ
  Serial.println("LED: OFF");
  delay(offTime);
}

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);  // เริ่มต้นปิดไฟไว้ก่อน
  Serial.begin(115200);
  Serial.println("\n===========================");
  Serial.println(" NodeMCU: 3-Cha Rhythm Ready! ");
  Serial.println("===========================");
}

void loop() {
  Serial.println("\n>>> จังหวะ 3 ช่า! <<<");

  // จังหวะ 3 ช่ายอดฮิต: "แต๊... แต-แตะ-แต-แต๊!"
  beat(220, 150, "แต๊...");    // จังหวะที่ 1
  beat(120, 100, "แต-");      // จังหวะที่ 2 (เคาะเร็ว)
  beat(120, 100, "แตะ-");     // จังหวะที่ 3 (เคาะเร็ว)
  beat(200, 150, "แต-");      // จังหวะที่ 4
  beat(450, 800, "แต๊!!!");   // จังหวะที่ 5 (ลากยาว แล้วพักก่อนขึ้นรอบใหม่)
}
