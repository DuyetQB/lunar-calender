import Foundation
@main
struct Main {
  static func main() {
    let e = LunarEngine()
    func c(_ d:Int,_ m:Int,_ y:Int){
      let l = e.solarToLunar(date: SolarDate(year:y,month:m,day:d))
      print("\(d)/\(m)/\(y) -> \(l.day)/\(l.month)/\(l.year) leap=\(l.isLeapMonth)")
    }
    c(1,8,2002)
    c(29,4,2001)
    c(1,1,2024)
  }
}
